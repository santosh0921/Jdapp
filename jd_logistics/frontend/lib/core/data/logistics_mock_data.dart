// JD Logistics — Enterprise Mock Data Engine

class LGoods {
  final String id, name, category, subCategory, hsn;
  final double gstRate;
  final String riskLevel; // low | medium | medium_high | high | critical | perishable
  final String classType; // easy | heavy | fragile | perishable | hazardous | high_value | temp_controlled | oversized | container
  final double baseRatePerKg; // ₹/kg for pricing
  final String emoji;

  const LGoods({
    required this.id,
    required this.name,
    required this.category,
    required this.subCategory,
    required this.hsn,
    required this.gstRate,
    required this.riskLevel,
    required this.classType,
    required this.baseRatePerKg,
    required this.emoji,
  });
}

class LCity {
  final String name, state, country, code;
  final bool hasPort, hasAirport, hasICD;
  const LCity({required this.name, required this.state, required this.country, required this.code, this.hasPort = false, this.hasAirport = false, this.hasICD = false});
}

class LPort {
  final String name, city, country, code, type; // sea | air | ICD
  final String emoji;
  const LPort({required this.name, required this.city, required this.country, required this.code, required this.type, required this.emoji});
}

class LWarehouse {
  final String name, city, state, code;
  final double totalCapacity, availableCapacity; // sq ft
  final List<String> features; // cold_storage | bonded | ICD | hazmat
  final double ratePerSqFtPerDay;
  const LWarehouse({required this.name, required this.city, required this.state, required this.code, required this.totalCapacity, required this.availableCapacity, required this.features, required this.ratePerSqFtPerDay});
}

class LVehicle {
  final String name, type, id;
  final double minTons, maxTons;
  final double baseCostPerKm;
  final String emoji;
  final List<String> suitable; // good categories it's suitable for
  const LVehicle({required this.name, required this.type, required this.id, required this.minTons, required this.maxTons, required this.baseCostPerKm, required this.emoji, required this.suitable});
}

class LRoute {
  final String from, to, fromCode, toCode;
  final double distanceKm;
  final int transitDays;
  final String type; // road | rail | sea | air
  const LRoute({required this.from, required this.to, required this.fromCode, required this.toCode, required this.distanceKm, required this.transitDays, required this.type});
}

class LPricingResult {
  final double baseFreight;
  final double distanceCost;
  final double weightCost;
  final double vehicleCost;
  final double riskCost;
  final double handlingCharges;
  final double insurancePremium;
  final double warehouseCharges;
  final double documentationCharges;
  final double customsCharges;
  final double gstAmount;
  final double totalAmount;
  final String vehicleRecommended;
  final String riskLevel;
  final double insuranceCoverage;

  const LPricingResult({
    required this.baseFreight,
    required this.distanceCost,
    required this.weightCost,
    required this.vehicleCost,
    required this.riskCost,
    required this.handlingCharges,
    required this.insurancePremium,
    required this.warehouseCharges,
    required this.documentationCharges,
    required this.customsCharges,
    required this.gstAmount,
    required this.totalAmount,
    required this.vehicleRecommended,
    required this.riskLevel,
    required this.insuranceCoverage,
  });

  double get subTotal => totalAmount - gstAmount;
}

// ─────────────────────────────────────────────────────────────────────────────
// MASTER DATA
// ─────────────────────────────────────────────────────────────────────────────

class LogisticsMockData {

  // ── GOODS DATABASE (100+ items) ──────────────────────────────────────────

  static const List<LGoods> goods = [
    // METALS
    LGoods(id: 'M001', name: 'Steel Coils', category: 'Metals', subCategory: 'Steel', hsn: '7208', gstRate: 18, riskLevel: 'medium', classType: 'heavy', baseRatePerKg: 2.5, emoji: '🔩'),
    LGoods(id: 'M002', name: 'Steel Bars / TMT', category: 'Metals', subCategory: 'Steel', hsn: '7214', gstRate: 18, riskLevel: 'medium', classType: 'heavy', baseRatePerKg: 2.2, emoji: '🔩'),
    LGoods(id: 'M003', name: 'Iron Ore', category: 'Metals', subCategory: 'Iron', hsn: '2601', gstRate: 5, riskLevel: 'low', classType: 'heavy', baseRatePerKg: 1.8, emoji: '⛏️'),
    LGoods(id: 'M004', name: 'Aluminium Sheets', category: 'Metals', subCategory: 'Aluminium', hsn: '7606', gstRate: 18, riskLevel: 'medium', classType: 'heavy', baseRatePerKg: 3.2, emoji: '🔲'),
    LGoods(id: 'M005', name: 'Copper Wire', category: 'Metals', subCategory: 'Copper', hsn: '7408', gstRate: 18, riskLevel: 'medium_high', classType: 'high_value', baseRatePerKg: 6.5, emoji: '🔌'),
    LGoods(id: 'M006', name: 'Stainless Steel Pipes', category: 'Metals', subCategory: 'Steel', hsn: '7304', gstRate: 18, riskLevel: 'medium', classType: 'heavy', baseRatePerKg: 4.0, emoji: '🔩'),
    LGoods(id: 'M007', name: 'Industrial Parts (Metal)', category: 'Metals', subCategory: 'Industrial Parts', hsn: '8466', gstRate: 18, riskLevel: 'medium', classType: 'heavy', baseRatePerKg: 5.0, emoji: '⚙️'),

    // MACHINERY
    LGoods(id: 'MC001', name: 'CNC Machine', category: 'Machinery', subCategory: 'CNC Machines', hsn: '8457', gstRate: 18, riskLevel: 'high', classType: 'oversized', baseRatePerKg: 8.0, emoji: '🏭'),
    LGoods(id: 'MC002', name: 'Generator Set', category: 'Machinery', subCategory: 'Generators', hsn: '8502', gstRate: 18, riskLevel: 'high', classType: 'oversized', baseRatePerKg: 6.5, emoji: '⚡'),
    LGoods(id: 'MC003', name: 'Excavator / JCB', category: 'Machinery', subCategory: 'Construction Equipment', hsn: '8429', gstRate: 18, riskLevel: 'high', classType: 'oversized', baseRatePerKg: 5.5, emoji: '🚜'),
    LGoods(id: 'MC004', name: 'Industrial Pumps', category: 'Machinery', subCategory: 'Industrial Equipment', hsn: '8413', gstRate: 18, riskLevel: 'medium_high', classType: 'heavy', baseRatePerKg: 5.0, emoji: '⚙️'),
    LGoods(id: 'MC005', name: 'Conveyor Systems', category: 'Machinery', subCategory: 'Industrial Equipment', hsn: '8428', gstRate: 18, riskLevel: 'high', classType: 'oversized', baseRatePerKg: 7.0, emoji: '🏭'),
    LGoods(id: 'MC006', name: 'Textile Machinery', category: 'Machinery', subCategory: 'Industrial Equipment', hsn: '8444', gstRate: 18, riskLevel: 'high', classType: 'oversized', baseRatePerKg: 6.0, emoji: '🧶'),
    LGoods(id: 'MC007', name: 'Boiler / Pressure Vessel', category: 'Machinery', subCategory: 'Industrial Equipment', hsn: '8402', gstRate: 18, riskLevel: 'critical', classType: 'hazardous', baseRatePerKg: 9.0, emoji: '🔥'),

    // TEXTILES
    LGoods(id: 'T001', name: 'Cotton Fabric', category: 'Textiles', subCategory: 'Fabric', hsn: '5208', gstRate: 5, riskLevel: 'low', classType: 'easy', baseRatePerKg: 1.5, emoji: '🧶'),
    LGoods(id: 'T002', name: 'Ready Made Garments', category: 'Textiles', subCategory: 'Garments', hsn: '6205', gstRate: 12, riskLevel: 'low', classType: 'easy', baseRatePerKg: 2.0, emoji: '👔'),
    LGoods(id: 'T003', name: 'Raw Cotton', category: 'Textiles', subCategory: 'Cotton', hsn: '5201', gstRate: 0, riskLevel: 'low', classType: 'easy', baseRatePerKg: 1.2, emoji: '☁️'),
    LGoods(id: 'T004', name: 'Synthetic Yarn', category: 'Textiles', subCategory: 'Raw Material', hsn: '5402', gstRate: 12, riskLevel: 'low', classType: 'easy', baseRatePerKg: 1.8, emoji: '🧵'),
    LGoods(id: 'T005', name: 'Silk Fabric', category: 'Textiles', subCategory: 'Fabric', hsn: '5007', gstRate: 5, riskLevel: 'medium_high', classType: 'high_value', baseRatePerKg: 4.0, emoji: '✨'),

    // FOOD
    LGoods(id: 'F001', name: 'Basmati Rice', category: 'Food', subCategory: 'Rice', hsn: '1006', gstRate: 5, riskLevel: 'low', classType: 'easy', baseRatePerKg: 1.0, emoji: '🍚'),
    LGoods(id: 'F002', name: 'Wheat / Atta', category: 'Food', subCategory: 'Wheat', hsn: '1001', gstRate: 0, riskLevel: 'low', classType: 'easy', baseRatePerKg: 0.8, emoji: '🌾'),
    LGoods(id: 'F003', name: 'Sugar', category: 'Food', subCategory: 'Sugar', hsn: '1701', gstRate: 5, riskLevel: 'low', classType: 'easy', baseRatePerKg: 0.9, emoji: '🍬'),
    LGoods(id: 'F004', name: 'Pulses / Dal', category: 'Food', subCategory: 'Pulses', hsn: '0713', gstRate: 0, riskLevel: 'low', classType: 'easy', baseRatePerKg: 1.1, emoji: '🫘'),
    LGoods(id: 'F005', name: 'Edible Oil', category: 'Food', subCategory: 'Oil', hsn: '1511', gstRate: 5, riskLevel: 'low', classType: 'easy', baseRatePerKg: 1.3, emoji: '🫙'),
    LGoods(id: 'F006', name: 'Spices (Bulk)', category: 'Food', subCategory: 'Spices', hsn: '0904', gstRate: 5, riskLevel: 'medium', classType: 'easy', baseRatePerKg: 3.0, emoji: '🌶️'),

    // PERISHABLE
    LGoods(id: 'P001', name: 'Fresh Fruits', category: 'Perishable', subCategory: 'Fruits', hsn: '0803', gstRate: 0, riskLevel: 'perishable', classType: 'perishable', baseRatePerKg: 3.5, emoji: '🍎'),
    LGoods(id: 'P002', name: 'Vegetables (Fresh)', category: 'Perishable', subCategory: 'Vegetables', hsn: '0701', gstRate: 0, riskLevel: 'perishable', classType: 'perishable', baseRatePerKg: 2.5, emoji: '🥦'),
    LGoods(id: 'P003', name: 'Fresh Flowers', category: 'Perishable', subCategory: 'Flowers', hsn: '0603', gstRate: 5, riskLevel: 'perishable', classType: 'perishable', baseRatePerKg: 8.0, emoji: '💐'),
    LGoods(id: 'P004', name: 'Dairy Products', category: 'Perishable', subCategory: 'Dairy', hsn: '0401', gstRate: 5, riskLevel: 'perishable', classType: 'temp_controlled', baseRatePerKg: 4.0, emoji: '🥛'),
    LGoods(id: 'P005', name: 'Frozen Seafood', category: 'Perishable', subCategory: 'Frozen Food', hsn: '0306', gstRate: 5, riskLevel: 'perishable', classType: 'temp_controlled', baseRatePerKg: 6.0, emoji: '🐟'),
    LGoods(id: 'P006', name: 'Frozen Meat', category: 'Perishable', subCategory: 'Frozen Food', hsn: '0201', gstRate: 12, riskLevel: 'perishable', classType: 'temp_controlled', baseRatePerKg: 5.5, emoji: '🥩'),
    LGoods(id: 'P007', name: 'Ice Cream / Cold Desserts', category: 'Perishable', subCategory: 'Frozen Food', hsn: '2105', gstRate: 18, riskLevel: 'perishable', classType: 'temp_controlled', baseRatePerKg: 4.5, emoji: '🍦'),

    // CHEMICALS
    LGoods(id: 'CH001', name: 'Industrial Chemicals', category: 'Chemicals', subCategory: 'Industrial Chemicals', hsn: '2915', gstRate: 18, riskLevel: 'critical', classType: 'hazardous', baseRatePerKg: 7.0, emoji: '⚗️'),
    LGoods(id: 'CH002', name: 'Paints & Coatings', category: 'Chemicals', subCategory: 'Paints', hsn: '3208', gstRate: 18, riskLevel: 'high', classType: 'hazardous', baseRatePerKg: 4.5, emoji: '🎨'),
    LGoods(id: 'CH003', name: 'Fertilizers (Bulk)', category: 'Chemicals', subCategory: 'Fertilizers', hsn: '3102', gstRate: 5, riskLevel: 'high', classType: 'hazardous', baseRatePerKg: 2.5, emoji: '🌱'),
    LGoods(id: 'CH004', name: 'Hazardous Chemicals', category: 'Chemicals', subCategory: 'Hazardous Goods', hsn: '2901', gstRate: 18, riskLevel: 'critical', classType: 'hazardous', baseRatePerKg: 12.0, emoji: '☠️'),
    LGoods(id: 'CH005', name: 'Petroleum Products', category: 'Chemicals', subCategory: 'Industrial Chemicals', hsn: '2710', gstRate: 18, riskLevel: 'critical', classType: 'hazardous', baseRatePerKg: 5.0, emoji: '⛽'),

    // ELECTRONICS
    LGoods(id: 'E001', name: 'Mobile Phones', category: 'Electronics', subCategory: 'Consumer Electronics', hsn: '8517', gstRate: 18, riskLevel: 'high', classType: 'high_value', baseRatePerKg: 15.0, emoji: '📱'),
    LGoods(id: 'E002', name: 'Laptops / Computers', category: 'Electronics', subCategory: 'Computers', hsn: '8471', gstRate: 18, riskLevel: 'high', classType: 'high_value', baseRatePerKg: 12.0, emoji: '💻'),
    LGoods(id: 'E003', name: 'Industrial Electronics', category: 'Electronics', subCategory: 'Industrial Electronics', hsn: '8543', gstRate: 18, riskLevel: 'medium_high', classType: 'fragile', baseRatePerKg: 10.0, emoji: '🔌'),
    LGoods(id: 'E004', name: 'Medical Devices', category: 'Electronics', subCategory: 'Medical Devices', hsn: '9018', gstRate: 12, riskLevel: 'high', classType: 'fragile', baseRatePerKg: 18.0, emoji: '🏥'),
    LGoods(id: 'E005', name: 'Solar Panels', category: 'Electronics', subCategory: 'Industrial Electronics', hsn: '8541', gstRate: 12, riskLevel: 'medium', classType: 'fragile', baseRatePerKg: 5.0, emoji: '☀️'),
    LGoods(id: 'E006', name: 'Televisions', category: 'Electronics', subCategory: 'Consumer Electronics', hsn: '8528', gstRate: 28, riskLevel: 'high', classType: 'fragile', baseRatePerKg: 8.0, emoji: '📺'),

    // PHARMACEUTICAL
    LGoods(id: 'PH001', name: 'Medicines / Drugs', category: 'Pharmaceutical', subCategory: 'Medicines', hsn: '3004', gstRate: 12, riskLevel: 'high', classType: 'high_value', baseRatePerKg: 20.0, emoji: '💊'),
    LGoods(id: 'PH002', name: 'Medical Equipment', category: 'Pharmaceutical', subCategory: 'Medical Equipment', hsn: '9019', gstRate: 12, riskLevel: 'high', classType: 'fragile', baseRatePerKg: 15.0, emoji: '🩺'),
    LGoods(id: 'PH003', name: 'Vaccines (Cold Chain)', category: 'Pharmaceutical', subCategory: 'Vaccines', hsn: '3002', gstRate: 5, riskLevel: 'critical', classType: 'temp_controlled', baseRatePerKg: 35.0, emoji: '💉'),
    LGoods(id: 'PH004', name: 'Bulk Drug API', category: 'Pharmaceutical', subCategory: 'Medicines', hsn: '2941', gstRate: 12, riskLevel: 'high', classType: 'high_value', baseRatePerKg: 25.0, emoji: '🧪'),

    // AUTOMOBILE
    LGoods(id: 'AU001', name: 'Vehicle Parts (Auto)', category: 'Automobile', subCategory: 'Vehicle Parts', hsn: '8708', gstRate: 28, riskLevel: 'medium', classType: 'heavy', baseRatePerKg: 4.5, emoji: '🚗'),
    LGoods(id: 'AU002', name: 'Tyres & Tubes', category: 'Automobile', subCategory: 'Tyres', hsn: '4011', gstRate: 28, riskLevel: 'medium', classType: 'heavy', baseRatePerKg: 3.5, emoji: '🛞'),
    LGoods(id: 'AU003', name: 'Two Wheeler Parts', category: 'Automobile', subCategory: 'Spare Parts', hsn: '8714', gstRate: 18, riskLevel: 'medium', classType: 'easy', baseRatePerKg: 3.0, emoji: '🏍️'),
    LGoods(id: 'AU004', name: 'Containers (Empty)', category: 'Automobile', subCategory: 'Containers', hsn: '8609', gstRate: 18, riskLevel: 'low', classType: 'container', baseRatePerKg: 2.0, emoji: '📦'),

    // RAW MATERIAL
    LGoods(id: 'RM001', name: 'Cement (Bulk)', category: 'Raw Material', subCategory: 'Cement', hsn: '2523', gstRate: 28, riskLevel: 'low', classType: 'heavy', baseRatePerKg: 0.7, emoji: '🏗️'),
    LGoods(id: 'RM002', name: 'Coal (Industrial)', category: 'Raw Material', subCategory: 'Coal', hsn: '2701', gstRate: 5, riskLevel: 'medium', classType: 'heavy', baseRatePerKg: 0.6, emoji: '🖤'),
    LGoods(id: 'RM003', name: 'Granite / Marble Stone', category: 'Raw Material', subCategory: 'Stone', hsn: '2516', gstRate: 28, riskLevel: 'low', classType: 'heavy', baseRatePerKg: 1.5, emoji: '🪨'),
    LGoods(id: 'RM004', name: 'Construction Sand', category: 'Raw Material', subCategory: 'Sand', hsn: '2505', gstRate: 5, riskLevel: 'low', classType: 'heavy', baseRatePerKg: 0.4, emoji: '🏜️'),
    LGoods(id: 'RM005', name: 'Industrial Minerals', category: 'Raw Material', subCategory: 'Industrial Minerals', hsn: '2519', gstRate: 5, riskLevel: 'low', classType: 'heavy', baseRatePerKg: 0.9, emoji: '⛏️'),
    LGoods(id: 'RM006', name: 'Limestone', category: 'Raw Material', subCategory: 'Industrial Minerals', hsn: '2521', gstRate: 5, riskLevel: 'low', classType: 'heavy', baseRatePerKg: 0.5, emoji: '🪨'),
  ];

  // ── CITIES ───────────────────────────────────────────────────────────────

  static const List<LCity> cities = [
    // Tier 1 — India
    LCity(name: 'Mumbai', state: 'Maharashtra', country: 'India', code: 'BOM', hasPort: true, hasAirport: true, hasICD: true),
    LCity(name: 'Delhi / NCR', state: 'Delhi', country: 'India', code: 'DEL', hasAirport: true, hasICD: true),
    LCity(name: 'Chennai', state: 'Tamil Nadu', country: 'India', code: 'MAA', hasPort: true, hasAirport: true, hasICD: true),
    LCity(name: 'Kolkata', state: 'West Bengal', country: 'India', code: 'CCU', hasPort: true, hasAirport: true, hasICD: true),
    LCity(name: 'Bengaluru', state: 'Karnataka', country: 'India', code: 'BLR', hasAirport: true, hasICD: true),
    LCity(name: 'Hyderabad', state: 'Telangana', country: 'India', code: 'HYD', hasAirport: true, hasICD: true),
    LCity(name: 'Ahmedabad', state: 'Gujarat', country: 'India', code: 'AMD', hasAirport: true, hasICD: true),
    LCity(name: 'Pune', state: 'Maharashtra', country: 'India', code: 'PNQ', hasAirport: true, hasICD: true),
    // Tier 2 — India
    LCity(name: 'Surat', state: 'Gujarat', country: 'India', code: 'STV', hasPort: true),
    LCity(name: 'Ludhiana', state: 'Punjab', country: 'India', code: 'LDH', hasICD: true),
    LCity(name: 'Coimbatore', state: 'Tamil Nadu', country: 'India', code: 'CJB', hasAirport: true),
    LCity(name: 'Visakhapatnam', state: 'Andhra Pradesh', country: 'India', code: 'VTZ', hasPort: true, hasAirport: true),
    LCity(name: 'Kochi', state: 'Kerala', country: 'India', code: 'COK', hasPort: true, hasAirport: true),
    LCity(name: 'Jaipur', state: 'Rajasthan', country: 'India', code: 'JAI', hasAirport: true, hasICD: true),
    LCity(name: 'Kanpur', state: 'Uttar Pradesh', country: 'India', code: 'KNU', hasICD: true),
    LCity(name: 'Nagpur', state: 'Maharashtra', country: 'India', code: 'NAG', hasAirport: true, hasICD: true),
    LCity(name: 'Bhopal', state: 'Madhya Pradesh', country: 'India', code: 'BHO'),
    LCity(name: 'Patna', state: 'Bihar', country: 'India', code: 'PAT'),
    LCity(name: 'Guwahati', state: 'Assam', country: 'India', code: 'GAU', hasAirport: true),
    LCity(name: 'Bhiwandi', state: 'Maharashtra', country: 'India', code: 'BWD', hasICD: true),
    LCity(name: 'Nhava Sheva', state: 'Maharashtra', country: 'India', code: 'JNPT', hasPort: true, hasICD: true),
    // International
    LCity(name: 'Dubai', state: 'Dubai', country: 'UAE', code: 'DXB', hasPort: true, hasAirport: true),
    LCity(name: 'Shanghai', state: 'Shanghai', country: 'China', code: 'SHA', hasPort: true, hasAirport: true),
    LCity(name: 'Singapore', state: 'Singapore', country: 'Singapore', code: 'SIN', hasPort: true, hasAirport: true),
    LCity(name: 'Rotterdam', state: 'South Holland', country: 'Netherlands', code: 'RTM', hasPort: true, hasAirport: true),
    LCity(name: 'Hamburg', state: 'Hamburg', country: 'Germany', code: 'HAM', hasPort: true, hasAirport: true),
    LCity(name: 'Colombo', state: 'Western Province', country: 'Sri Lanka', code: 'CMB', hasPort: true, hasAirport: true),
    LCity(name: 'Jebel Ali', state: 'Dubai', country: 'UAE', code: 'JEA', hasPort: true),
    LCity(name: 'Hong Kong', state: 'Hong Kong', country: 'China', code: 'HKG', hasPort: true, hasAirport: true),
    LCity(name: 'Antwerp', state: 'Flanders', country: 'Belgium', code: 'ANR', hasPort: true),
  ];

  // ── PORTS ────────────────────────────────────────────────────────────────

  static const List<LPort> ports = [
    LPort(name: 'Jawaharlal Nehru Port (JNPT)', city: 'Nhava Sheva', country: 'India', code: 'INJNP', type: 'sea', emoji: '⚓'),
    LPort(name: 'Mumbai Port', city: 'Mumbai', country: 'India', code: 'INBOM', type: 'sea', emoji: '🚢'),
    LPort(name: 'Chennai Port', city: 'Chennai', country: 'India', code: 'INMAA', type: 'sea', emoji: '⚓'),
    LPort(name: 'Kolkata Port (Syama Prasad)', city: 'Kolkata', country: 'India', code: 'INCCU', type: 'sea', emoji: '🚢'),
    LPort(name: 'Visakhapatnam Port', city: 'Visakhapatnam', country: 'India', code: 'INVTZ', type: 'sea', emoji: '⚓'),
    LPort(name: 'Kochi Port', city: 'Kochi', country: 'India', code: 'INCOK', type: 'sea', emoji: '🚢'),
    LPort(name: 'Mundra Port', city: 'Mundra', country: 'India', code: 'INMUN', type: 'sea', emoji: '⚓'),
    LPort(name: 'Kandla / Deendayal Port', city: 'Gandhidham', country: 'India', code: 'INKND', type: 'sea', emoji: '🚢'),
    LPort(name: 'Delhi ICD (TKD)', city: 'Delhi', country: 'India', code: 'INTKD', type: 'ICD', emoji: '🏭'),
    LPort(name: 'Ludhiana ICD', city: 'Ludhiana', country: 'India', code: 'INLDH', type: 'ICD', emoji: '🏭'),
    LPort(name: 'Chhatrapati Shivaji Int. Airport', city: 'Mumbai', country: 'India', code: 'BOM', type: 'air', emoji: '✈️'),
    LPort(name: 'Indira Gandhi Int. Airport', city: 'Delhi', country: 'India', code: 'DEL', type: 'air', emoji: '✈️'),
    LPort(name: 'Chennai Int. Airport', city: 'Chennai', country: 'India', code: 'MAA', type: 'air', emoji: '✈️'),
    // International
    LPort(name: 'Jebel Ali Port', city: 'Dubai', country: 'UAE', code: 'AEJEA', type: 'sea', emoji: '🚢'),
    LPort(name: 'Port of Shanghai', city: 'Shanghai', country: 'China', code: 'CNSHA', type: 'sea', emoji: '⚓'),
    LPort(name: 'Port of Singapore', city: 'Singapore', country: 'Singapore', code: 'SGSIN', type: 'sea', emoji: '🚢'),
    LPort(name: 'Port of Rotterdam', city: 'Rotterdam', country: 'Netherlands', code: 'NLRTM', type: 'sea', emoji: '⚓'),
    LPort(name: 'Port of Hamburg', city: 'Hamburg', country: 'Germany', code: 'DEHAM', type: 'sea', emoji: '🚢'),
    LPort(name: 'Port of Colombo', city: 'Colombo', country: 'Sri Lanka', code: 'LKCMB', type: 'sea', emoji: '⚓'),
    LPort(name: 'Dubai International Airport', city: 'Dubai', country: 'UAE', code: 'DXB', type: 'air', emoji: '✈️'),
  ];

  // ── WAREHOUSES ───────────────────────────────────────────────────────────

  static const List<LWarehouse> warehouses = [
    LWarehouse(name: 'JD Hub Mumbai Central', city: 'Mumbai', state: 'Maharashtra', code: 'JD-MUM-01', totalCapacity: 250000, availableCapacity: 82000, features: ['bonded', 'cold_storage', 'ICD'], ratePerSqFtPerDay: 1.8),
    LWarehouse(name: 'JD Hub Nhava Sheva', city: 'Nhava Sheva', state: 'Maharashtra', code: 'JD-JNPT-01', totalCapacity: 400000, availableCapacity: 145000, features: ['bonded', 'ICD', 'hazmat'], ratePerSqFtPerDay: 2.2),
    LWarehouse(name: 'JD Hub Delhi NCR', city: 'Delhi', state: 'Delhi', code: 'JD-DEL-01', totalCapacity: 300000, availableCapacity: 95000, features: ['ICD', 'bonded'], ratePerSqFtPerDay: 2.0),
    LWarehouse(name: 'JD Hub Chennai Port', city: 'Chennai', state: 'Tamil Nadu', code: 'JD-MAA-01', totalCapacity: 200000, availableCapacity: 62000, features: ['bonded', 'cold_storage'], ratePerSqFtPerDay: 1.6),
    LWarehouse(name: 'JD Hub Bengaluru', city: 'Bengaluru', state: 'Karnataka', code: 'JD-BLR-01', totalCapacity: 180000, availableCapacity: 55000, features: ['ICD'], ratePerSqFtPerDay: 1.9),
    LWarehouse(name: 'JD Hub Ahmedabad', city: 'Ahmedabad', state: 'Gujarat', code: 'JD-AMD-01', totalCapacity: 220000, availableCapacity: 78000, features: ['bonded', 'hazmat'], ratePerSqFtPerDay: 1.5),
    LWarehouse(name: 'JD Cold Chain Pune', city: 'Pune', state: 'Maharashtra', code: 'JD-PNQ-CC', totalCapacity: 80000, availableCapacity: 22000, features: ['cold_storage'], ratePerSqFtPerDay: 3.5),
    LWarehouse(name: 'JD Hub Kolkata', city: 'Kolkata', state: 'West Bengal', code: 'JD-CCU-01', totalCapacity: 170000, availableCapacity: 48000, features: ['bonded', 'ICD'], ratePerSqFtPerDay: 1.4),
    LWarehouse(name: 'JD Hub Hyderabad', city: 'Hyderabad', state: 'Telangana', code: 'JD-HYD-01', totalCapacity: 160000, availableCapacity: 51000, features: ['ICD'], ratePerSqFtPerDay: 1.7),
    LWarehouse(name: 'JD Hazmat Facility Surat', city: 'Surat', state: 'Gujarat', code: 'JD-STV-HZ', totalCapacity: 60000, availableCapacity: 18000, features: ['hazmat'], ratePerSqFtPerDay: 4.0),
  ];

  // ── VEHICLES ─────────────────────────────────────────────────────────────

  static const List<LVehicle> vehicles = [
    LVehicle(name: 'Pickup Truck', type: 'road', id: 'VH01', minTons: 0, maxTons: 0.75, baseCostPerKm: 12, emoji: '🛻', suitable: ['Electronics', 'Pharmaceutical', 'Textiles']),
    LVehicle(name: 'Mini Truck (Tata Ace)', type: 'road', id: 'VH02', minTons: 0.75, maxTons: 1.5, baseCostPerKm: 18, emoji: '🚐', suitable: ['Food', 'Textiles', 'Electronics']),
    LVehicle(name: 'Medium Truck (Tata 407)', type: 'road', id: 'VH03', minTons: 1.5, maxTons: 4, baseCostPerKm: 28, emoji: '🚛', suitable: ['Food', 'Metals', 'Automobile']),
    LVehicle(name: 'Heavy Truck (14 Wheeler)', type: 'road', id: 'VH04', minTons: 4, maxTons: 20, baseCostPerKm: 45, emoji: '🚚', suitable: ['Metals', 'Machinery', 'Raw Material']),
    LVehicle(name: 'Container Truck (40ft)', type: 'road', id: 'VH05', minTons: 15, maxTons: 30, baseCostPerKm: 65, emoji: '🚛', suitable: ['Metals', 'Machinery', 'Chemicals']),
    LVehicle(name: 'Trailer / Multi Axle', type: 'road', id: 'VH06', minTons: 20, maxTons: 60, baseCostPerKm: 85, emoji: '🚚', suitable: ['Machinery', 'Raw Material', 'Automobile']),
    LVehicle(name: 'Refrigerated Truck', type: 'road', id: 'VH07', minTons: 0, maxTons: 10, baseCostPerKm: 55, emoji: '❄️', suitable: ['Perishable', 'Pharmaceutical']),
    LVehicle(name: 'Cargo Train (Rail)', type: 'rail', id: 'VH08', minTons: 50, maxTons: 5000, baseCostPerKm: 8, emoji: '🚂', suitable: ['Raw Material', 'Metals', 'Food', 'Chemicals']),
    LVehicle(name: '20ft Sea Container', type: 'sea', id: 'VH09', minTons: 0, maxTons: 25, baseCostPerKm: 0.5, emoji: '📦', suitable: ['Metals', 'Textiles', 'Automobile', 'Electronics']),
    LVehicle(name: '40ft Sea Container (HC)', type: 'sea', id: 'VH10', minTons: 0, maxTons: 28, baseCostPerKm: 0.7, emoji: '🚢', suitable: ['Metals', 'Machinery', 'Chemicals', 'Food']),
    LVehicle(name: 'Bulk Vessel', type: 'sea', id: 'VH11', minTons: 10000, maxTons: 200000, baseCostPerKm: 0.2, emoji: '🛳️', suitable: ['Raw Material', 'Food', 'Chemicals']),
    LVehicle(name: 'Air Cargo', type: 'air', id: 'VH12', minTons: 0, maxTons: 100, baseCostPerKm: 180, emoji: '✈️', suitable: ['Electronics', 'Pharmaceutical', 'Perishable']),
    LVehicle(name: 'Express Air Cargo', type: 'air', id: 'VH13', minTons: 0, maxTons: 50, baseCostPerKm: 280, emoji: '🛫', suitable: ['Pharmaceutical', 'Electronics', 'Perishable']),
  ];

  // ── MOCK ROUTES (distance in km) ─────────────────────────────────────────

  static const List<LRoute> routes = [
    LRoute(from: 'Mumbai', to: 'Delhi', fromCode: 'BOM', toCode: 'DEL', distanceKm: 1420, transitDays: 2, type: 'road'),
    LRoute(from: 'Mumbai', to: 'Chennai', fromCode: 'BOM', toCode: 'MAA', distanceKm: 1340, transitDays: 2, type: 'road'),
    LRoute(from: 'Mumbai', to: 'Bengaluru', fromCode: 'BOM', toCode: 'BLR', distanceKm: 984, transitDays: 1, type: 'road'),
    LRoute(from: 'Mumbai', to: 'Ahmedabad', fromCode: 'BOM', toCode: 'AMD', distanceKm: 528, transitDays: 1, type: 'road'),
    LRoute(from: 'Mumbai', to: 'Kolkata', fromCode: 'BOM', toCode: 'CCU', distanceKm: 1979, transitDays: 3, type: 'road'),
    LRoute(from: 'Delhi', to: 'Chennai', fromCode: 'DEL', toCode: 'MAA', distanceKm: 2185, transitDays: 3, type: 'road'),
    LRoute(from: 'Mumbai', to: 'Dubai', fromCode: 'INJNP', toCode: 'AEJEA', distanceKm: 2800, transitDays: 6, type: 'sea'),
    LRoute(from: 'Chennai', to: 'Singapore', fromCode: 'INMAA', toCode: 'SGSIN', distanceKm: 3600, transitDays: 8, type: 'sea'),
    LRoute(from: 'Mumbai', to: 'Rotterdam', fromCode: 'INJNP', toCode: 'NLRTM', distanceKm: 12500, transitDays: 28, type: 'sea'),
    LRoute(from: 'Mumbai', to: 'Shanghai', fromCode: 'INJNP', toCode: 'CNSHA', distanceKm: 8200, transitDays: 18, type: 'sea'),
    LRoute(from: 'Delhi', to: 'Dubai (Air)', fromCode: 'DEL', toCode: 'DXB', distanceKm: 2200, transitDays: 1, type: 'air'),
    LRoute(from: 'Mumbai', to: 'Dubai (Air)', fromCode: 'BOM', toCode: 'DXB', distanceKm: 1960, transitDays: 1, type: 'air'),
    LRoute(from: 'Chennai', to: 'Singapore (Air)', fromCode: 'MAA', toCode: 'SIN', distanceKm: 2900, transitDays: 1, type: 'air'),
    LRoute(from: 'Mumbai', to: 'Hamburg', fromCode: 'INJNP', toCode: 'DEHAM', distanceKm: 11800, transitDays: 25, type: 'sea'),
    LRoute(from: 'Kolkata', to: 'Singapore', fromCode: 'INCCU', toCode: 'SGSIN', distanceKm: 3200, transitDays: 7, type: 'sea'),
  ];

  // ── IMPORT COUNTRIES ──────────────────────────────────────────────────────

  static const List<Map<String, String>> importCountries = [
    {'name': 'China', 'flag': '🇨🇳', 'code': 'CN'},
    {'name': 'Germany', 'flag': '🇩🇪', 'code': 'DE'},
    {'name': 'Japan', 'flag': '🇯🇵', 'code': 'JP'},
    {'name': 'South Korea', 'flag': '🇰🇷', 'code': 'KR'},
    {'name': 'USA', 'flag': '🇺🇸', 'code': 'US'},
    {'name': 'Netherlands', 'flag': '🇳🇱', 'code': 'NL'},
    {'name': 'UAE', 'flag': '🇦🇪', 'code': 'AE'},
    {'name': 'Italy', 'flag': '🇮🇹', 'code': 'IT'},
    {'name': 'Belgium', 'flag': '🇧🇪', 'code': 'BE'},
    {'name': 'Australia', 'flag': '🇦🇺', 'code': 'AU'},
    {'name': 'Brazil', 'flag': '🇧🇷', 'code': 'BR'},
    {'name': 'Russia', 'flag': '🇷🇺', 'code': 'RU'},
    {'name': 'Malaysia', 'flag': '🇲🇾', 'code': 'MY'},
    {'name': 'Indonesia', 'flag': '🇮🇩', 'code': 'ID'},
    {'name': 'Singapore', 'flag': '🇸🇬', 'code': 'SG'},
    {'name': 'UK', 'flag': '🇬🇧', 'code': 'GB'},
    {'name': 'France', 'flag': '🇫🇷', 'code': 'FR'},
    {'name': 'Saudi Arabia', 'flag': '🇸🇦', 'code': 'SA'},
    {'name': 'Iran', 'flag': '🇮🇷', 'code': 'IR'},
    {'name': 'Sri Lanka', 'flag': '🇱🇰', 'code': 'LK'},
  ];

  static const List<Map<String, String>> exportCountries = [
    {'name': 'USA', 'flag': '🇺🇸', 'code': 'US'},
    {'name': 'UAE', 'flag': '🇦🇪', 'code': 'AE'},
    {'name': 'UK', 'flag': '🇬🇧', 'code': 'GB'},
    {'name': 'Germany', 'flag': '🇩🇪', 'code': 'DE'},
    {'name': 'Netherlands', 'flag': '🇳🇱', 'code': 'NL'},
    {'name': 'Bangladesh', 'flag': '🇧🇩', 'code': 'BD'},
    {'name': 'Sri Lanka', 'flag': '🇱🇰', 'code': 'LK'},
    {'name': 'Singapore', 'flag': '🇸🇬', 'code': 'SG'},
    {'name': 'Hong Kong', 'flag': '🇭🇰', 'code': 'HK'},
    {'name': 'Australia', 'flag': '🇦🇺', 'code': 'AU'},
    {'name': 'South Africa', 'flag': '🇿🇦', 'code': 'ZA'},
    {'name': 'Kenya', 'flag': '🇰🇪', 'code': 'KE'},
    {'name': 'Nigeria', 'flag': '🇳🇬', 'code': 'NG'},
    {'name': 'Japan', 'flag': '🇯🇵', 'code': 'JP'},
    {'name': 'Canada', 'flag': '🇨🇦', 'code': 'CA'},
    {'name': 'Brazil', 'flag': '🇧🇷', 'code': 'BR'},
    {'name': 'Saudi Arabia', 'flag': '🇸🇦', 'code': 'SA'},
    {'name': 'Qatar', 'flag': '🇶🇦', 'code': 'QA'},
    {'name': 'Oman', 'flag': '🇴🇲', 'code': 'OM'},
    {'name': 'Italy', 'flag': '🇮🇹', 'code': 'IT'},
  ];

  // ── GOODS CLASSIFICATION ENGINE ─────────────────────────────────────────

  static String classifyGoods(String category) {
    switch (category) {
      case 'Perishable': return 'perishable';
      case 'Chemicals': return 'hazardous';
      case 'Electronics': return 'high_value';
      case 'Pharmaceutical': return 'high_value';
      case 'Metals': return 'heavy';
      case 'Machinery': return 'oversized';
      case 'Raw Material': return 'heavy';
      case 'Textiles': return 'easy';
      case 'Food': return 'easy';
      case 'Automobile': return 'heavy';
      default: return 'easy';
    }
  }

  static String classifyLabel(String classType) {
    const m = {
      'easy': 'Easy Goods',
      'heavy': 'Heavy Goods',
      'fragile': 'Fragile Goods',
      'perishable': 'Perishable Goods',
      'hazardous': 'Hazardous Goods',
      'high_value': 'High Value Goods',
      'temp_controlled': 'Temperature Controlled',
      'oversized': 'Oversized Cargo',
      'container': 'Container Cargo',
    };
    return m[classType] ?? 'Standard Goods';
  }

  // ── VEHICLE RECOMMENDATION ENGINE ────────────────────────────────────────

  static LVehicle recommendVehicle({
    required double weightTons,
    required String shipmentType, // road | sea | air | rail
    required String classType,
    required bool isUrgent,
  }) {
    if (classType == 'perishable' || classType == 'temp_controlled') {
      return vehicles.firstWhere((v) => v.id == 'VH07');
    }
    if (shipmentType == 'air' || isUrgent) {
      return classType == 'high_value'
          ? vehicles.firstWhere((v) => v.id == 'VH13')
          : vehicles.firstWhere((v) => v.id == 'VH12');
    }
    if (shipmentType == 'sea') {
      if (weightTons > 25) return vehicles.firstWhere((v) => v.id == 'VH11');
      if (weightTons > 15) return vehicles.firstWhere((v) => v.id == 'VH10');
      return vehicles.firstWhere((v) => v.id == 'VH09');
    }
    if (shipmentType == 'rail') return vehicles.firstWhere((v) => v.id == 'VH08');
    // Road
    if (weightTons <= 0.75) return vehicles.firstWhere((v) => v.id == 'VH01');
    if (weightTons <= 1.5) return vehicles.firstWhere((v) => v.id == 'VH02');
    if (weightTons <= 4) return vehicles.firstWhere((v) => v.id == 'VH03');
    if (weightTons <= 20) return vehicles.firstWhere((v) => v.id == 'VH04');
    if (weightTons <= 30) return vehicles.firstWhere((v) => v.id == 'VH05');
    return vehicles.firstWhere((v) => v.id == 'VH06');
  }

  // ── RISK ENGINE ──────────────────────────────────────────────────────────

  static double riskMultiplier(String riskLevel) {
    switch (riskLevel) {
      case 'low': return 1.0;
      case 'medium': return 1.15;
      case 'medium_high': return 1.30;
      case 'high': return 1.50;
      case 'critical': return 2.0;
      case 'perishable': return 1.45;
      default: return 1.0;
    }
  }

  static double insuranceRate(String riskLevel, String classType) {
    // % of goods value
    if (classType == 'hazardous' || riskLevel == 'critical') return 2.5;
    if (riskLevel == 'high' || classType == 'high_value') return 1.8;
    if (riskLevel == 'perishable' || classType == 'temp_controlled') return 2.0;
    if (riskLevel == 'medium_high') return 1.2;
    if (riskLevel == 'medium') return 0.8;
    return 0.5;
  }

  // ── FREIGHT PRICING ENGINE ───────────────────────────────────────────────

  static LPricingResult calculateFreight({
    required LGoods goods,
    required double weightKg,
    required double distanceKm,
    required LVehicle vehicle,
    required bool isExport,
    required bool needsWarehouse,
    required double goodsValue,
  }) {
    final wt = weightKg;
    final dist = distanceKm;

    final baseFreight = goods.baseRatePerKg * wt;
    final distanceCost = vehicle.baseCostPerKm * dist;
    final weightCost = wt * 1.2;
    final vehicleCost = vehicle.type == 'air' ? wt * 85 : vehicle.type == 'sea' ? wt * 12 : wt * 8;
    final risk = riskMultiplier(goods.riskLevel);
    final riskCost = (baseFreight + distanceCost) * (risk - 1);
    final handlingCharges = wt * 3.5 * (goods.classType == 'hazardous' ? 2.5 : goods.classType == 'fragile' ? 1.8 : 1.0);
    final insRate = insuranceRate(goods.riskLevel, goods.classType) / 100;
    final insurancePremium = goodsValue * insRate;
    final warehouseCharges = needsWarehouse ? wt * 15 : 0.0;
    final documentationCharges = isExport ? 4500.0 : 2500.0;
    final customsCharges = isExport ? goodsValue * 0.01 : goodsValue * 0.015;

    final sub = baseFreight + distanceCost + weightCost + vehicleCost + riskCost + handlingCharges + insurancePremium + warehouseCharges + documentationCharges + customsCharges;
    final gstAmount = sub * (goods.gstRate / 100);
    final total = sub + gstAmount;

    return LPricingResult(
      baseFreight: baseFreight,
      distanceCost: distanceCost,
      weightCost: weightCost,
      vehicleCost: vehicleCost,
      riskCost: riskCost,
      handlingCharges: handlingCharges,
      insurancePremium: insurancePremium,
      warehouseCharges: warehouseCharges,
      documentationCharges: documentationCharges,
      customsCharges: customsCharges,
      gstAmount: gstAmount,
      totalAmount: total,
      vehicleRecommended: vehicle.name,
      riskLevel: goods.riskLevel,
      insuranceCoverage: goodsValue * (1 + insRate),
    );
  }

  // ── WEIGHT CONVERSION ─────────────────────────────────────────────────────

  static double toKg(double value, String unit) {
    switch (unit) {
      case 'Quintal': return value * 100;
      case 'Ton': return value * 1000;
      case 'Metric Ton': return value * 1000;
      case '20ft Container': return value * 18000;
      case '40ft Container': return value * 26000;
      default: return value;
    }
  }

  static double toTons(double kg) => kg / 1000;

  // ── AI RECOMMENDATIONS ────────────────────────────────────────────────────

  static List<Map<String, String>> aiRecommendations({
    required LGoods goods,
    required double weightKg,
    required String shipmentType,
    required bool isUrgent,
  }) {
    final List<Map<String, String>> recs = [];

    // Mode recommendation
    if (goods.classType == 'perishable' && shipmentType != 'air') {
      recs.add({'icon': '🛫', 'title': 'Switch to Air Cargo', 'desc': 'Perishable goods need fastest mode. Air cargo recommended.'});
    }
    if (weightKg > 20000 && shipmentType == 'road') {
      recs.add({'icon': '🚂', 'title': 'Use Rail Freight', 'desc': 'For ${(weightKg/1000).toStringAsFixed(0)} MT, rail is 40% cheaper than road.'});
    }
    if (goods.classType == 'hazardous') {
      recs.add({'icon': '⚠️', 'title': 'HAZMAT Handling Required', 'desc': 'Special packaging, certified driver and manifests needed.'});
    }
    if (goods.classType == 'high_value') {
      recs.add({'icon': '🛡️', 'title': 'Enhanced Insurance', 'desc': 'High-value goods. Upgrade to comprehensive cover.'});
    }
    if (goods.classType == 'temp_controlled') {
      recs.add({'icon': '❄️', 'title': 'Cold Chain Needed', 'desc': 'Temperature must stay 2°C–8°C. Reefer truck assigned.'});
    }
    recs.add({'icon': '📄', 'title': 'Pre-book Customs', 'desc': 'Submit documents 48hr before shipping to avoid port delays.'});

    return recs;
  }

  // ── QUICK LOOKUP HELPERS ──────────────────────────────────────────────────

  static List<String> get goodsCategories => goods.map((g) => g.category).toSet().toList();

  static List<LGoods> goodsByCategory(String category) =>
      goods.where((g) => g.category == category).toList();

  static LGoods? goodsById(String id) => goods.where((g) => g.id == id).firstOrNull;

  static LRoute? findRoute(String fromCode, String toCode) =>
      routes.where((r) => r.fromCode == fromCode && r.toCode == toCode).firstOrNull;

  static double estimateDistance(String from, String to) {
    final r = routes.where((r) => r.from == from || r.fromCode == from).toList();
    return r.isNotEmpty ? r.first.distanceKm : 1200;
  }

  static String riskLabel(String level) {
    const m = {
      'low': 'Low Risk',
      'medium': 'Medium Risk',
      'medium_high': 'Medium-High Risk',
      'high': 'High Risk',
      'critical': 'Critical Risk',
      'perishable': 'Perishable',
    };
    return m[level] ?? 'Standard';
  }

  static List<String> containerTypes = [
    '20ft Standard (TEU)',
    '40ft Standard',
    '40ft High Cube (HC)',
    '20ft Refrigerated',
    '40ft Refrigerated',
    'Open Top Container',
    'Flat Rack Container',
    'Tank Container',
    'Bulk Container',
    'LCL (Less Container Load)',
  ];

  static List<String> weightUnits = ['KG', 'Quintal', 'Ton', 'Metric Ton', '20ft Container', '40ft Container'];
}
