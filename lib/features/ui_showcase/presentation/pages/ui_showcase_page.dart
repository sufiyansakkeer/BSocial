import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/ui_constants.dart';
import '../../../../core/widgets/animations/bs_animated_container.dart';
import '../../../../core/widgets/avatars/bs_avatar.dart';
import '../../../../core/widgets/buttons/bs_button.dart';
import '../../../../core/widgets/cards/bs_card.dart';
import '../../../../core/widgets/inputs/bs_text_field.dart';

/// A page that showcases the UI components of BSocial
class UIShowcasePage extends StatefulWidget {
  /// Creates a UI showcase page
  const UIShowcasePage({super.key});

  @override
  State<UIShowcasePage> createState() => _UIShowcasePageState();
}

class _UIShowcasePageState extends State<UIShowcasePage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('UI Showcase'),
          centerTitle: true,
        ),
        body: BSStaggeredList(
          itemDuration: UiConstants.animMedium,
          initialDelay: const Duration(milliseconds: 100),
          children: [
            _buildSection(
              title: 'Typography',
              child: _buildTypographyShowcase(),
            ),
            _buildSection(
              title: 'Colors',
              child: _buildColorsShowcase(),
            ),
            _buildSection(
              title: 'Buttons',
              child: _buildButtonsShowcase(),
            ),
            _buildSection(
              title: 'Text Fields',
              child: _buildTextFieldsShowcase(),
            ),
            _buildSection(
              title: 'Cards',
              child: _buildCardsShowcase(),
            ),
            _buildSection(
              title: 'Avatars',
              child: _buildAvatarsShowcase(),
            ),
            _buildSection(
              title: 'Animations',
              child: _buildAnimationsShowcase(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      );

  Widget _buildSection({required String title, required Widget child}) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            child,
            const Divider(height: 32),
          ],
        ),
      );

  Widget _buildTypographyShowcase() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Display Large', style: theme.textTheme.displayLarge),
        Text('Display Medium', style: theme.textTheme.displayMedium),
        Text('Display Small', style: theme.textTheme.displaySmall),
        Text('Headline Large', style: theme.textTheme.headlineLarge),
        Text('Headline Medium', style: theme.textTheme.headlineMedium),
        Text('Headline Small', style: theme.textTheme.headlineSmall),
        Text('Title Large', style: theme.textTheme.titleLarge),
        Text('Title Medium', style: theme.textTheme.titleMedium),
        Text('Title Small', style: theme.textTheme.titleSmall),
        Text('Body Large', style: theme.textTheme.bodyLarge),
        Text('Body Medium', style: theme.textTheme.bodyMedium),
        Text('Body Small', style: theme.textTheme.bodySmall),
        Text('Label Large', style: theme.textTheme.labelLarge),
        Text('Label Medium', style: theme.textTheme.labelMedium),
        Text('Label Small', style: theme.textTheme.labelSmall),
      ],
    );
  }

  Widget _buildColorsShowcase() => Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          _buildColorItem('Primary', AppColors.primaryColor),
          _buildColorItem('Primary Variant', AppColors.primaryVariant),
          _buildColorItem('Primary Light', AppColors.primaryLight),
          _buildColorItem('Secondary', AppColors.secondaryColor),
          _buildColorItem('Secondary Variant', AppColors.secondaryVariant),
          _buildColorItem('Secondary Light', AppColors.secondaryLight),
          _buildColorItem('Accent Pink', AppColors.accentPink),
          _buildColorItem('Accent Purple', AppColors.accentPurple),
          _buildColorItem('Accent Orange', AppColors.accentOrange),
          _buildColorItem('Error', AppColors.error),
          _buildColorItem('Success', AppColors.success),
          _buildColorItem('Warning', AppColors.warning),
        ],
      );

  Widget _buildColorItem(String name, Color color) {
    final textColor =
        color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(UiConstants.borderRadiusMedium),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              name,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtonsShowcase() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              BSButton(
                label: 'Primary',
                onPressed: () {},
              ),
              BSButton(
                label: 'Secondary',
                onPressed: () {},
                type: BSButtonType.secondary,
              ),
              BSButton(
                label: 'Outlined',
                onPressed: () {},
                type: BSButtonType.outlined,
              ),
              BSButton(
                label: 'Text',
                onPressed: () {},
                type: BSButtonType.text,
              ),
            ],
          ),
          UiConstants.kHeight16,
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              BSButton(
                label: 'Small',
                onPressed: () {},
                size: BSButtonSize.small,
              ),
              BSButton(
                label: 'Medium',
                onPressed: () {},
              ),
              BSButton(
                label: 'Large',
                onPressed: () {},
                size: BSButtonSize.large,
              ),
            ],
          ),
          UiConstants.kHeight16,
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              BSButton(
                label: 'With Icon',
                onPressed: () {},
                icon: Icons.favorite,
              ),
              BSButton(
                label: 'Icon Right',
                onPressed: () {},
                icon: Icons.arrow_forward,
                iconPosition: IconPosition.right,
              ),
              BSButton(
                label: 'Loading',
                onPressed: _toggleLoading,
                isLoading: _isLoading,
              ),
              BSButton(
                label: 'Disabled',
                onPressed: () {},
                isDisabled: true,
              ),
            ],
          ),
          UiConstants.kHeight16,
          BSButton(
            label: 'Full Width Button',
            onPressed: () {},
            isFullWidth: true,
          ),
        ],
      );

  Widget _buildTextFieldsShowcase() => Column(
        children: [
          const BSTextField(
            labelText: 'Standard Text Field',
            hintText: 'Enter some text',
          ),
          UiConstants.kHeight16,
          BSTextField(
            labelText: 'With Prefix Icon',
            hintText: 'Search...',
            prefixIcon: const Icon(Icons.search),
            controller: _searchController,
          ),
          UiConstants.kHeight16,
          const BSTextField(
            labelText: 'Password Field',
            hintText: 'Enter your password',
            obscureText: true,
            togglePasswordVisibility: true,
          ),
          UiConstants.kHeight16,
          const BSTextField(
            labelText: 'With Error',
            hintText: 'Enter your email',
            errorText: 'Please enter a valid email address',
            keyboardType: TextInputType.emailAddress,
          ),
          UiConstants.kHeight16,
          const BSTextField(
            labelText: 'Multiline Text Field',
            hintText: 'Enter a longer text...',
            maxLines: 3,
          ),
        ],
      );

  Widget _buildCardsShowcase() => Column(
        children: [
          const BSCard(
            padding: EdgeInsets.all(16),
            child: Text('Basic Card'),
          ),
          UiConstants.kHeight16,
          BSContentCard(
            header: const Text('Card with Header and Footer'),
            content: const Text(
              'This is a card with a header and footer. '
              'It demonstrates how to use the BSContentCard component.',
            ),
            footer: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                BSButton(
                  label: 'Cancel',
                  onPressed: () {},
                  type: BSButtonType.text,
                ),
                UiConstants.kWidth8,
                BSButton(
                  label: 'Submit',
                  onPressed: () {},
                ),
              ],
            ),
          ),
          UiConstants.kHeight16,
          BSCard(
            elevation: BSCardElevation.emphasized,
            padding: const EdgeInsets.all(16),
            onTap: () {},
            child: const Text('Tappable Card with Emphasized Elevation'),
          ),
        ],
      );

  Widget _buildAvatarsShowcase() => const Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          BSAvatar(
            initials: 'JD',
            size: BSAvatarSize.xs,
          ),
          BSAvatar(
            initials: 'JD',
            size: BSAvatarSize.sm,
          ),
          BSAvatar(
            initials: 'JD',
          ),
          BSAvatar(
            initials: 'JD',
            size: BSAvatarSize.lg,
          ),
          BSAvatar(
            initials: 'JD',
            size: BSAvatarSize.xl,
          ),
          BSAvatar(
            imageUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
            size: BSAvatarSize.lg,
          ),
          BSAvatar(
            imageUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
            size: BSAvatarSize.lg,
            isOnline: true,
          ),
          BSAvatar(
            initials: 'BS',
            size: BSAvatarSize.lg,
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            borderColor: AppColors.secondaryColor,
            borderWidth: 2,
          ),
          BSAvatar(
            initials: 'AN',
            size: BSAvatarSize.lg,
            showAnimation: true,
          ),
        ],
      );

  Widget _buildAnimationsShowcase() => Column(
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildAnimationExample(
                'Fade',
                BSAnimationType.fade,
              ),
              _buildAnimationExample(
                'Scale',
                BSAnimationType.scale,
              ),
              _buildAnimationExample(
                'Slide',
                BSAnimationType.slide,
              ),
              _buildAnimationExample(
                'Fade & Scale',
                BSAnimationType.fadeScale,
              ),
              _buildAnimationExample(
                'Fade & Slide',
                BSAnimationType.fadeSlide,
              ),
            ],
          ),
        ],
      );

  Widget _buildAnimationExample(String name, BSAnimationType type) => BSCard(
        padding: const EdgeInsets.all(16),
        width: 150,
        height: 100,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(name, style: Theme.of(context).textTheme.titleSmall),
              UiConstants.kHeight8,
              BSButton(
                label: 'Animate',
                onPressed: () {
                  // This would trigger the animation in a real implementation
                },
                size: BSButtonSize.small,
              ),
            ],
          ),
        ),
      );
}
