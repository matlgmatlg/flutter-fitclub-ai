import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/common/index.dart';
import '../providers/language_provider.dart';
import 'package:provider/provider.dart';
import '../core/translations.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'dart:async';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _pricingKey = GlobalKey();
  bool _isScrolled = false;
  
  // Map to track section visibility states
  final Map<String, bool> _sectionVisibility = {
    'hero': false,
    'features': false,
    'demo': false,
    'testimonials': false,
    'pricing': false,
    'cta': false,
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 20 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 20 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  String _t(String key) {
    final language = Provider.of<LanguageProvider>(context).currentLanguage;
    return Translations.get(language, key);
  }

  // Helper method to wrap sections with fade animation
  Widget _wrapWithAnimation(String sectionId, Widget child) {
    return VisibilityDetector(
      key: Key(sectionId),
      onVisibilityChanged: (visibilityInfo) {
        // Trigger animation when just 15% of the section is visible (down from 30%)
        if (visibilityInfo.visibleFraction > 0.15 && !_sectionVisibility[sectionId]!) {
          setState(() {
            _sectionVisibility[sectionId] = true;
          });
        }
      },
      child: AnimatedOpacity(
        opacity: _sectionVisibility[sectionId]! ? 1.0 : 0.0,
        // Reduced duration for faster animation
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut, // Changed to easeOut for snappier feel
        child: AnimatedSlide(
          offset: _sectionVisibility[sectionId]! ? Offset.zero : const Offset(0, 0.05), // Reduced slide distance
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut, // Changed to easeOut for snappier feel
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Initialize visibility states if not already set
    _sectionVisibility.forEach((key, value) {
      _sectionVisibility[key] ??= false;
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _isScrolled 
              ? AppTheme.backgroundColor.withOpacity(0.95)
              : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(_isScrolled ? 0.1 : 0),
                width: 1,
              ),
            ),
            boxShadow: _isScrolled
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
          ),
          child: AppBar(
            toolbarHeight: 80,
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            centerTitle: false,
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // FitClub Logo with hover effect
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        // Scroll to top when logo is clicked
                        _scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.easeInOutCubic,
                        );
                      },
                      child: _buildAnimatedLogo(context),
                    ),
                  ),
                  const SizedBox(width: 64),
                  
                  // Menu Items with enhanced interactivity
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _buildAnimatedMenuButton(
                            _t('for_coaches'),
                            [
                              PopupMenuItem(
                                value: 'coaching_platform',
                                child: Text(_t('coaching_platform')),
                              ),
                              PopupMenuItem(
                                value: 'coach_success_stories',
                                child: Text(_t('coach_success_stories')),
                              ),
                              PopupMenuItem(
                                value: 'start_coaching',
                                child: Text(_t('start_coaching')),
                              ),
                            ],
                          ),
                          const SizedBox(width: 32),
                          _buildAnimatedMenuButton(
                            _t('for_athletes'),
                            [
                              PopupMenuItem(
                                value: 'athlete_features',
                                child: Text(_t('athlete_features')),
                              ),
                              PopupMenuItem(
                                value: 'athlete_success_stories',
                                child: Text(_t('athlete_success_stories')),
                              ),
                              PopupMenuItem(
                                value: 'get_app',
                                child: Text(_t('get_app')),
                              ),
                            ],
                          ),
                          const SizedBox(width: 32),
                          _buildAnimatedMenuButton(
                            _t('learning'),
                            [
                              PopupMenuItem(
                                value: 'learning_coaches',
                                child: Text(_t('learning_coaches')),
                              ),
                              PopupMenuItem(
                                value: 'learning_athletes',
                                child: Text(_t('learning_athletes')),
                              ),
                            ],
                          ),
                          const SizedBox(width: 32),
                          _buildAnimatedTextButton(
                            _t('pricing')[0].toUpperCase() + _t('pricing').substring(1).toLowerCase(),
                            onPressed: () => _scrollToSection(_pricingKey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _t('login').toUpperCase(),
                        style: TextStyle(
                          color: AppTheme.primaryTextColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w100,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    _buildAnimatedButton(
                      text: _t('get_started').toUpperCase(),
                      onPressed: () => Navigator.pushNamed(context, '/register'),
                    ),
                    const SizedBox(width: 32),
                    LanguageSelector(
                      currentLanguage: Provider.of<LanguageProvider>(context).currentLanguage,
                      onLanguageChanged: (language) {
                        Provider.of<LanguageProvider>(context, listen: false)
                            .setLanguage(language);
                      },
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background with parallax effect
          _buildParallaxBackground(),
          
          // Content with smooth scrolling
          SingleChildScrollView(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                _wrapWithAnimation('hero', _buildHeroSection(context)),
                _wrapWithAnimation('features', _buildFeaturesSection(context, _featuresKey)),
                _wrapWithAnimation('demo', _buildDemoSection(context)),
                _wrapWithAnimation('testimonials', _buildTestimonialsSection(context)),
                _wrapWithAnimation('pricing', _buildPricingSection(context, _pricingKey)),
                _wrapWithAnimation('cta', _buildCtaSection(context)),
                _buildFooter(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParallaxBackground() {
    return AnimatedBuilder(
      animation: _scrollController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor.withOpacity(0.1),
                AppTheme.backgroundColor,
              ],
              stops: [
                0.0,
                (_scrollController.hasClients 
                  ? (_scrollController.offset / 1000).clamp(0.3, 0.7)
                  : 0.3),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedLogo(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.9, end: 1.0),
      duration: const Duration(milliseconds: 200),
      builder: (context, double scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Fit',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w100,
                fontSize: 28,
                letterSpacing: 0.5,
              ),
            ),
            TextSpan(
              text: 'Club',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.primaryColor.withOpacity(0.9),
                fontWeight: FontWeight.w100,
                fontSize: 28,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedMenuButton(String text, List<PopupMenuItem<String>> items, {VoidCallback? onTap}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0.95, end: 1.0),
        duration: const Duration(milliseconds: 200),
        builder: (context, double scale, child) {
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: HoverMenu(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.transparent,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: AppTheme.primaryTextColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w100,
                    height: 1.2,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: AppTheme.primaryTextColor,
                  size: 18,
                ),
              ],
            ),
          ),
          items: items.map((item) => MenuItemData(
            value: item.value ?? '',
            text: (item.child as Text).data ?? '',
          )).toList(),
          onSelected: (_) => onTap?.call(),
        ),
      ),
    );
  }

  Widget _buildAnimatedTextButton(String text, {required VoidCallback onPressed}) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppTheme.primaryTextColor,
          fontSize: 15,
          fontWeight: FontWeight.w100,
          height: 1.2,
        ),
      ),
    );
  }

  Widget _buildAnimatedButton({required String text, required VoidCallback onPressed}) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0.95, end: 1.0),
        duration: const Duration(milliseconds: 200),
        builder: (context, double scale, child) {
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: AppButton(
          text: text,
          onPressed: onPressed,
          variant: AppButtonVariant.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 200, bottom: 130, left: 24, right: 24),
      child: Column(
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Fit',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w100,
                    letterSpacing: 0.5,
                  ),
                ),
                TextSpan(
                  text: 'Club',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w100,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Text(
            _t('hero_title').toUpperCase(),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.primaryTextColor,
              fontWeight: FontWeight.w100,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            _t('hero_subtitle'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.secondaryTextColor,
              fontWeight: FontWeight.w100,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppButton(
                text: _t('start_free').toUpperCase(),
                onPressed: () => Navigator.pushNamed(context, '/register'),
                variant: AppButtonVariant.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              const SizedBox(width: 16),
              AppButton(
                text: _t('watch_demo').toUpperCase(),
                onPressed: () {},
                variant: AppButtonVariant.outline,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context, GlobalKey key) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Column(
        children: [
          Text(
            _t('features').toUpperCase(),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w100,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFeatureCard(
                context,
                Icons.analytics_outlined,
                _t('ai_form_analysis'),
                _t('ai_form_description'),
              ),
              const SizedBox(width: 24),
              _buildFeatureCard(
                context,
                Icons.people_outline,
                _t('client_management'),
                _t('client_management_description'),
              ),
              const SizedBox(width: 24),
              _buildFeatureCard(
                context,
                Icons.fitness_center_outlined,
                _t('workout_creator'),
                _t('workout_creator_description'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, IconData icon, String title, String description) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.primaryTextColor,
              fontWeight: FontWeight.w100,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.secondaryTextColor,
              fontWeight: FontWeight.w100,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDemoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Column(
        children: [
          Text(
            _t('demo_section_title').toUpperCase(),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w100,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 800,
            height: 450,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.withOpacity(0.2),
              ),
            ),
            child: Center(
              child: Text(_t('demo_video_placeholder')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _t('testimonials_title').toUpperCase(),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w100,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTestimonialCard(
                context,
                _t('testimonial_1_name'),
                _t('testimonial_1_role'),
                _t('testimonial_1_text'),
                'https://i.pravatar.cc/150?img=1',
              ),
              const SizedBox(width: 24),
              _buildTestimonialCard(
                context,
                _t('testimonial_2_name'),
                _t('testimonial_2_role'),
                _t('testimonial_2_text'),
                'https://i.pravatar.cc/150?img=2',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard(BuildContext context, String name, String role, String text, String imageUrl) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(imageUrl),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.primaryTextColor,
              fontWeight: FontWeight.w100,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            role,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.secondaryTextColor,
              fontWeight: FontWeight.w100,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.primaryTextColor,
              fontWeight: FontWeight.w100,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection(BuildContext context, GlobalKey key) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _t('pricing_title').toUpperCase(),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w100,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPricingCard(
                context,
                _t('pricing_starter'),
                '\$49',
                _t('pricing_starter_subtitle'),
                [
                  _t('pricing_feature_clients_20'),
                  _t('pricing_feature_basic_ai'),
                  _t('pricing_feature_management'),
                  _t('pricing_feature_workout'),
                ],
                false,
              ),
              const SizedBox(width: 24),
              _buildPricingCard(
                context,
                _t('pricing_professional'),
                '\$99',
                _t('pricing_professional_subtitle'),
                [
                  _t('pricing_feature_clients_unlimited'),
                  _t('pricing_feature_advanced_ai'),
                  _t('pricing_feature_support'),
                  _t('pricing_feature_branding'),
                ],
                true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard(BuildContext context, String tier, String price, String description, List<String> features, bool isPro) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isPro ? AppTheme.primaryColor.withOpacity(0.1) : AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPro ? AppTheme.primaryColor : Colors.grey.withOpacity(0.2),
          width: isPro ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            tier,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.primaryTextColor,
              fontWeight: FontWeight.w100,
              letterSpacing: 0.8,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            price,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w100,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            _t('pricing_per_month'),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.secondaryTextColor,
              fontWeight: FontWeight.w100,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.secondaryTextColor,
              fontWeight: FontWeight.w100,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    feature,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryTextColor,
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 24),
          AppButton(
            text: (isPro ? _t('start_free_trial') : _t('get_started')).toUpperCase(),
            onPressed: () => Navigator.pushNamed(context, '/register'),
            variant: isPro ? AppButtonVariant.primary : AppButtonVariant.outline,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCtaSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Column(
        children: [
          Text(
            _t('cta_title').toUpperCase(),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w100,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _t('cta_subtitle'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.secondaryTextColor,
              fontWeight: FontWeight.w100,
            ),
          ),
          const SizedBox(height: 32),
          AppButton(
            text: _t('start_trial').toUpperCase(),
            onPressed: () => Navigator.pushNamed(context, '/register'),
            variant: AppButtonVariant.primary,
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      color: AppTheme.surfaceColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _t('copyright'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.secondaryTextColor,
              fontWeight: FontWeight.w100,
            ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {},
                child: Text(
                  _t('privacy_policy'),
                  style: TextStyle(
                    color: AppTheme.secondaryTextColor,
                    fontWeight: FontWeight.w100,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              TextButton(
                onPressed: () {},
                child: Text(
                  _t('terms_of_service'),
                  style: TextStyle(
                    color: AppTheme.secondaryTextColor,
                    fontWeight: FontWeight.w100,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              TextButton(
                onPressed: () {},
                child: Text(
                  _t('contact_us'),
                  style: TextStyle(
                    color: AppTheme.secondaryTextColor,
                    fontWeight: FontWeight.w100,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Add HoverMenu widget
class HoverMenu extends StatefulWidget {
  final Widget child;
  final List<MenuItemData> items;
  final Function(String)? onSelected;

  const HoverMenu({
    Key? key,
    required this.child,
    required this.items,
    this.onSelected,
  }) : super(key: key);

  @override
  _HoverMenuState createState() => _HoverMenuState();
}

class MenuItemData {
  final String value;
  final String text;

  const MenuItemData({
    required this.value,
    required this.text,
  });
}

class _HoverMenuState extends State<HoverMenu> {
  final GlobalKey _key = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isHovered = false;
  Timer? _closeTimer;
  bool _isOverlayHovered = false;
  final Map<String, bool> _itemHoverStates = {};

  @override
  void initState() {
    super.initState();
    for (var item in widget.items) {
      _itemHoverStates[item.value] = false;
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    _closeTimer?.cancel();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _cancelCloseTimer() {
    _closeTimer?.cancel();
    _closeTimer = null;
  }

  void _startCloseTimer() {
    _cancelCloseTimer();
    _closeTimer = Timer(const Duration(milliseconds: 10), () {
      if (!_isHovered && !_isOverlayHovered) {
        _removeOverlay();
      }
    });
  }

  void _showOverlay(BuildContext context) {
    _cancelCloseTimer();
    
    if (_overlayEntry != null) {
      return;
    }

    final RenderBox renderBox = _key.currentContext!.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height,
        child: Material(
          color: Colors.transparent,
          child: MouseRegion(
            onEnter: (_) {
              _isOverlayHovered = true;
              _cancelCloseTimer();
            },
            onExit: (_) {
              _isOverlayHovered = false;
              _startCloseTimer();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Invisible bridge to prevent gap between button and menu
                Container(
                  height: 4,
                  width: size.width,
                  color: Colors.transparent,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IntrinsicWidth(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: widget.items.map((item) => 
                        StatefulBuilder(
                          builder: (context, setState) => MouseRegion(
                            cursor: SystemMouseCursors.click,
                            onEnter: (_) {
                              setState(() => _itemHoverStates[item.value] = true);
                              _cancelCloseTimer();
                            },
                            onExit: (_) => setState(() => _itemHoverStates[item.value] = false),
                            child: InkWell(
                              onTap: () {
                                widget.onSelected?.call(item.value);
                                _removeOverlay();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                decoration: BoxDecoration(
                                  color: _itemHoverStates[item.value]! 
                                    ? AppTheme.primaryColor.withOpacity(0.05)
                                    : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      item.text,
                                      style: TextStyle(
                                        color: _itemHoverStates[item.value]! 
                                          ? AppTheme.primaryColor
                                          : AppTheme.primaryTextColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      key: _key,
      onEnter: (_) {
        setState(() => _isHovered = true);
        _showOverlay(context);
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _startCloseTimer();
      },
      child: widget.child,
    );
  }
} 