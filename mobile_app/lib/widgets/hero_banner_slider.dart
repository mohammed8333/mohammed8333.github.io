import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pizza_awlad_alsheikh/core/constants/app_colors.dart';

class HeroBannerSlider extends StatefulWidget {
  final VoidCallback? onExploreMenu;

  const HeroBannerSlider({super.key, this.onExploreMenu});

  @override
  State<HeroBannerSlider> createState() => _HeroBannerSliderState();
}

class _HeroBannerSliderState extends State<HeroBannerSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> _banners = [
    {
      'title': 'أشهى بيتزا شرقية وإيطالية في إمبابة',
      'subtitle': 'عجينة طازجة ومكونات فاخرة تخبز خصيصاً لك 24 ساعة يومياً',
      'tag': 'الأكثر تميزاً 🍕',
      'image': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=800&q=80',
    },
    {
      'title': 'عرض الأكيلة: حواوشي وكريب وسوبريم',
      'subtitle': 'اطلب وجبتك المفضلة وسنصلك أينما كنت بأقصى سرعة',
      'tag': 'عروض ساخنة 🔥',
      'image': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&q=80',
    },
    {
      'title': 'فطير مشلتت فلاحي بالسمن البلدي الأصلي',
      'subtitle': 'مورق وخفيف ويقدم ساخناً مع العسل الأسود والطحينة أو الجبن',
      'tag': 'طعم زمان 🍯',
      'image': 'https://images.unsplash.com/photo-1608897013039-887f21d8c804?w=800&q=80',
    },
    {
      'title': 'طلبك عبر واتساب بضغطة زر واحدة',
      'subtitle': 'اختر وجبتك وأرسل تفاصيل طلبك مباشرة لمطعم بيتزا أولاد الشيخ',
      'tag': 'توصيل فوري 📲',
      'image': 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=800&q=80',
    },
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _banners.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 185,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(40),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Food Background Image
                      Image.network(
                        banner['image']!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.primaryDark,
                          child: const Icon(Icons.local_pizza, size: 60, color: Colors.white30),
                        ),
                      ),
                      // Gradient Overlay for Readability
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withAlpha(220),
                              Colors.black.withAlpha(120),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      // Text Content
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                banner['tag']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              banner['title']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              banner['subtitle']!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Dots Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (index) {
            final isSelected = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              width: isSelected ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.grey.withAlpha(120),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}
