import 'package:flutter/material.dart';
import 'food_item.dart';

void main() => runApp(const RestoApp());

const kGreen = Color.fromARGB(255, 182, 4, 4);
const kSaffron = Color.fromARGB(255, 255, 0, 0);
const kBg = Color(0xFFF4F8F6);
const kInk = Color(0xFF16231F);
const kMuted = Color.fromARGB(255, 0, 0, 0);

class RestoApp extends StatelessWidget {
  const RestoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'bibi Resto',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: kBg,
        colorScheme: ColorScheme.fromSeed(seedColor: kGreen, primary: kGreen),
      ),
      home: const MainShell(),
    );
  }
}

// STATEFUL: menyimpan data porsi & tab aktif.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;
  final List<FoodItem> _items = FoodItem.sampleData;

  int get _grandTotal => _items.fold(0, (s, e) => s + e.totalPrice);
  int get _totalPortions => _items.fold(0, (s, e) => s + e.quantity);

  Future<void> _openDetail(FoodItem item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailPage(item: item)),
    );
    setState(() {}); // refresh beranda setelah porsi diubah
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      MenuPage(
        items: _items,
        grandTotal: _grandTotal,
        totalPortions: _totalPortions,
        onTap: _openDetail,
      ),
      ProfilePage(
        name: 'bibi',
        items: _items,
        grandTotal: _grandTotal,
        totalPortions: _totalPortions,
      ),
    ];
    return Scaffold(
      body: pages[_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        backgroundColor: Colors.white,
        indicatorColor: kSaffron,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.restaurant_menu_outlined),
              selectedIcon: Icon(Icons.restaurant_menu, color: kInk),
              label: 'Menu'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: kInk),
              label: 'Profil'),
        ],
      ),
    );
  }
}

// ---------- Header bersama ----------
class Header extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? leading;
  const Header({super.key, required this.title, required this.subtitle, this.leading});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          12, MediaQuery.of(context).padding.top + 12, 20, 22),
      decoration: const BoxDecoration(
        color: kGreen,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        children: [
          leading ?? const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(color: Color(0xFFB8D6CF), fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget foodImage(String url, {double? h, double? w, double radius = 16}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: Image.network(
      url,
      height: h,
      width: w,
      fit: BoxFit.cover,
      loadingBuilder: (c, child, p) => p == null
          ? child
          : Container(height: h, width: w, color: const Color(0xFFE3EDE9)),
      errorBuilder: (c, e, s) => Container(
        height: h,
        width: w,
        color: const Color(0xFFE3EDE9),
        child: const Icon(Icons.fastfood, color: kMuted),
      ),
    ),
  );
}

// ---------- Halaman Beranda (STATELESS) ----------
class MenuPage extends StatelessWidget {
  final List<FoodItem> items;
  final int grandTotal;
  final int totalPortions;
  final void Function(FoodItem) onTap;

  const MenuPage({
    super.key,
    required this.items,
    required this.grandTotal,
    required this.totalPortions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Header(title: 'Menu Resto', subtitle: 'Mau makan apa hari ini?'),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (_, i) => _FoodCard(item: items[i], onTap: () => onTap(items[i])),
          ),
        ),
        if (totalPortions > 0)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: kInk,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(Icons.shopping_bag_outlined, color: kSaffron),
                const SizedBox(width: 10),
                Text('$totalPortions porsi',
                    style: const TextStyle(color: Colors.white70)),
                const Spacer(),
                Text('Rp ${formatPrice(grandTotal)}',
                    style: const TextStyle(
                        color: kSaffron, fontWeight: FontWeight.w800, fontSize: 17)),
              ],
            ),
          ),
      ],
    );
  }
}

class _FoodCard extends StatelessWidget {
  final FoodItem item;
  final VoidCallback onTap;
  const _FoodCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = item.quantity > 0;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: active ? kSaffron : const Color(0xFFE1EAE6),
                width: active ? 1.6 : 1),
          ),
          child: Row(
            children: [
              Hero(
                tag: item.name,
                child: foodImage(item.imageUrl, h: 96, w: 96),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800, color: kInk)),
                    const SizedBox(height: 3),
                    Text(item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: kMuted, height: 1.3)),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: active ? kSaffron : const Color(0xFFEAF1EE),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text('${item.quantity} porsi',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: kInk)),
                              ),
                              const SizedBox(height: 4),
                              Text('Rp ${item.formattedPrice} / porsi',
                                  style: const TextStyle(fontSize: 11, color: kMuted)),
                            ],
                          ),
                        ),
                        Text('Rp ${item.formattedTotal}',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: active ? kGreen : kMuted)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Halaman Detail/Edit (STATEFUL) ----------
class DetailPage extends StatefulWidget {
  final FoodItem item;
  const DetailPage({super.key, required this.item});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late int _qty;
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _qty = widget.item.quantity;
    _ctrl = TextEditingController(text: '$_qty');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _set(int v) {
    if (v < 0) v = 0;
    if (v > 99) v = 99;
    setState(() => _qty = v);
    _ctrl.value = TextEditingValue(
      text: '$v',
      selection: TextSelection.collapsed(offset: '$v'.length),
    );
  }

  void _save() {
    widget.item.quantity = _qty;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: kInk,
      content: Text('Pesanan ${widget.item.name} disimpan: $_qty porsi'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Scaffold(
      body: Column(
        children: [
          Header(
            title: item.name,
            subtitle: 'Atur jumlah porsi',
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Hero(
                  tag: item.name,
                  child: foodImage(item.imageUrl, h: 220, radius: 24),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFE1EAE6)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w800, color: kInk)),
                      const SizedBox(height: 4),
                      Text('Rp ${item.formattedPrice} / porsi',
                          style: const TextStyle(
                              color: kGreen, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      Text(item.description,
                          style: const TextStyle(color: kMuted, height: 1.4)),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          _RoundBtn(icon: Icons.remove, onTap: () => _set(_qty - 1)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _ctrl,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w800),
                              decoration: InputDecoration(
                                labelText: 'Jumlah (porsi)',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide:
                                      const BorderSide(color: kGreen, width: 2),
                                ),
                              ),
                              onChanged: (v) =>
                                  setState(() => _qty = int.tryParse(v) ?? 0),
                            ),
                          ),
                          const SizedBox(width: 12),
                          _RoundBtn(icon: Icons.add, onTap: () => _set(_qty + 1)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total',
                              style: TextStyle(fontSize: 15, color: kMuted)),
                          Text('Rp ${formatPrice(_qty * item.price)}',
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: kGreen)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: kSaffron,
                    foregroundColor: kInk,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _save,
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Simpan pemesanan',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFEAF1EE),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: kGreen),
        ),
      ),
    );
  }
}

// ---------- Halaman Profil (STATELESS) ----------
class ProfilePage extends StatelessWidget {
  final String name;
  final List<FoodItem> items;
  final int grandTotal;
  final int totalPortions;

  const ProfilePage({
    super.key,
    required this.name,
    required this.items,
    required this.grandTotal,
    required this.totalPortions,
  });

  @override
  Widget build(BuildContext context) {
    final ordered = items.where((e) => e.quantity > 0).toList();
    return Column(
      children: [
        const Header(title: 'Profil', subtitle: 'Akun pelanggan'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 8),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: kSaffron),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: kGreen,
                    child: Text(name[0].toUpperCase(),
                        style: const TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                            fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(name,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w800, color: kInk)),
              ),
              const Center(
                child: Text('Pelanggan Resto', style: TextStyle(color: kMuted)),
              ),
              const SizedBox(height: 22),
              _InfoTile(
                icon: Icons.restaurant_menu,
                title: 'Menu Resto',
                sub: 'Pesan makanan favoritmu dengan mudah.',
              ),
              const SizedBox(height: 10),
              _InfoTile(
                icon: Icons.receipt_long,
                title: 'Pemesanan',
                sub: ordered.isEmpty
                    ? 'Belum ada pesanan.'
                    : '${ordered.map((e) => '${e.name} x${e.quantity}').join(', ')}\n'
                        'Total $totalPortions porsi: Rp ${formatPrice(grandTotal)}',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  const _InfoTile({required this.icon, required this.title, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE1EAE6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: kSaffron,
            child: Icon(icon, color: kInk, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, color: kInk, fontSize: 15)),
                const SizedBox(height: 2),
                Text(sub,
                    style: const TextStyle(color: kMuted, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}