package middleware

import (
	"net/http"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
)

// RateLimiter implements a simple in-memory token-bucket per IP.
// For production scale use Redis-backed rate limiting.
type bucket struct {
	tokens    int
	lastReset time.Time
	mu        sync.Mutex
}

var (
	buckets   = make(map[string]*bucket)
	bucketsMu sync.Mutex
)

// RateLimit returns a middleware that limits to `maxReq` requests per `window`.
func RateLimit(maxReq int, window time.Duration) gin.HandlerFunc {
	return func(c *gin.Context) {
		ip := c.ClientIP()

		bucketsMu.Lock()
		b, ok := buckets[ip]
		if !ok {
			b = &bucket{tokens: maxReq, lastReset: time.Now()}
			buckets[ip] = b
		}
		bucketsMu.Unlock()

		b.mu.Lock()
		defer b.mu.Unlock()

		if time.Since(b.lastReset) > window {
			b.tokens = maxReq
			b.lastReset = time.Now()
		}

		if b.tokens <= 0 {
			c.Header("Retry-After", window.String())
			c.AbortWithStatusJSON(http.StatusTooManyRequests, gin.H{
				"success": false,
				"error":   "too many requests — please slow down",
			})
			return
		}

		b.tokens--
		c.Next()
	}
}
