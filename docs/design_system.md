# FitClub AI Design System

## Quick Reference

### Core Measurements
- **Primary Spacing**: 24px
- **Secondary Spacing**: 16px
- **Compact Spacing**: 8-12px
- **Border Radius (Large)**: 24px
- **Border Radius (Medium)**: 20px
- **Border Radius (Small)**: 16px
- **Border Radius (Compact)**: 12px

### Standard Opacities
- **Primary Elements**: 0.9
- **Secondary Elements**: 0.7
- **Tertiary Elements**: 0.5
- **Backgrounds**: 0.05
- **Secondary Backgrounds**: 0.03
- **Interactive Elements**: 0.07

### Text Sizes
- **Primary Header**: 28px
- **Secondary Header**: 18px
- **Card Header**: 16px
- **Body Text**: 15px
- **Label Text**: 14px

---

## 1. Base Components

### Page Container
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        Color(0xFF1A1A1A).withOpacity(0.95),
        Color(0xFF0A0A0A).withOpacity(0.95),
      ],
    ),
  ),
  child: Padding(
    padding: const EdgeInsets.all(24),
    child: YourContent(),
  ),
)
```

### Glassmorphic Container
```dart
ClipRRect(
  borderRadius: BorderRadius.circular(24),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
      ),
    ),
  ),
)
```

### Standard Card
```dart
Container(
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.03),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.white.withOpacity(0.1),
      width: 1,
    ),
  ),
)
```

---

## 2. Typography

### Headers
```dart
// H1 - Primary Header
TextStyle(
  color: Colors.white.withOpacity(0.9),
  fontSize: 28,
  fontWeight: FontWeight.w600,
)

// H2 - Secondary Header
TextStyle(
  color: Colors.white.withOpacity(0.9),
  fontSize: 18,
  fontWeight: FontWeight.w600,
)

// H3 - Card Header
TextStyle(
  color: Colors.white.withOpacity(0.9),
  fontSize: 16,
  fontWeight: FontWeight.w500,
)
```

### Body & Labels
```dart
// Body Text
TextStyle(
  color: Colors.white.withOpacity(0.7),
  fontSize: 15,
  height: 1.5,
)

// Label/Secondary Text
TextStyle(
  color: Colors.white.withOpacity(0.7),
  fontSize: 14,
  fontWeight: FontWeight.w500,
)
```

---

## 3. Interactive Elements

### Primary Button
```dart
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: AppTheme.primaryColor.withOpacity(0.9),
    borderRadius: BorderRadius.circular(16),
  ),
)
```

### Input Field
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.07),
    borderRadius: BorderRadius.circular(16),
  ),
  child: TextField(
    decoration: InputDecoration(
      borderSide: BorderSide.none,
      contentPadding: const EdgeInsets.all(16),
    ),
  ),
)
```

### Icon Button
```dart
Container(
  padding: const EdgeInsets.all(10),
  decoration: BoxDecoration(
    color: color.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Icon(
    icon,
    color: color.withOpacity(0.9),
    size: 20,
  ),
)
```

---

## 4. Color System

### Backgrounds
- **Page Background**: Dark gradient (0.95 opacity)
- **Primary Container**: `Colors.white.withOpacity(0.05)`
- **Secondary Container**: `Colors.white.withOpacity(0.03)`
- **Interactive Elements**: `Colors.white.withOpacity(0.07)`

### Text
- **Primary**: `Colors.white.withOpacity(0.9)`
- **Secondary**: `Colors.white.withOpacity(0.7)`
- **Hint/Disabled**: `Colors.white.withOpacity(0.5)`

### Accents
- **Primary Actions**: `AppTheme.primaryColor.withOpacity(0.9)`
- **Icons**: Context color with `0.9` opacity
- **Borders**: `Colors.white.withOpacity(0.1)`

---

## 5. Layout Guidelines

### Spacing
- Use 24px for major sections
- Use 16px for related elements
- Use 8-12px for compact elements
- Always add padding inside containers

### Responsive Design
- Use `Expanded` and `Flexible` for dynamic sizing
- Implement min/max constraints
- Use `MediaQuery` for breakpoints
- Consider tablet/desktop layouts

### Performance Tips
- Use `const` constructors
- Minimize nested containers
- Be mindful of blur effects
- Cache frequently used widgets

---

## 6. Best Practices

### Visual Hierarchy
✓ Use consistent spacing (8, 16, 24px)
✓ Larger elements for primary content
✓ Subtle backgrounds for secondary content
✓ Clear interactive element states

### Interaction Design
✓ Include hover states (MouseRegion)
✓ Consistent touch targets
✓ Clear feedback on interaction
✓ 300ms animations with ease-out

### Accessibility
✓ Maintain contrast ratios
✓ Use semantic colors
✓ Consistent interactive sizes
✓ Clear visual hierarchy
