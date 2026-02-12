import 'package:flutter/material.dart';

import '../models/bdui_action.dart';
import '../models/bdui_component.dart';
import 'component_registry.dart';

/// Регистрирует все встроенные компоненты в [registry].
void registerBuiltInComponents(ComponentRegistry registry) {
  registry.register('text', _buildText);
  registry.register('card', _buildCard);
  registry.register('list', _buildList);
  registry.register('list_tile', _buildListTile);
  registry.register('scroll_view', _buildScrollView);
  registry.register('button', _buildButton);
  registry.register('image', _buildImage);
  registry.register('spacer', _buildSpacer);
  registry.register('divider', _buildDivider);
  registry.register('row', _buildRow);
  registry.register('container', _buildContainer);
  registry.register('icon', _buildIcon);
  registry.register('badge', _buildBadge);
}

// =============================================================================
// text
// =============================================================================

Widget _buildText(
  BduiComponent c,
  List<Widget> children,
  void Function(BduiAction)? onAction,
) {
  final text = c.stringPropOr('text', '');
  final styleName = c.stringProp('style');
  final colorHex = c.stringProp('color');
  final maxLines = c.intProp('max_lines');
  final align = _parseTextAlign(c.stringProp('align'));

  return Builder(builder: (context) {
    var textStyle = _resolveTextStyle(context, styleName);
    if (colorHex != null) {
      textStyle = textStyle?.copyWith(color: _parseColor(colorHex));
    }

    final widget = Text(
      text,
      style: textStyle,
      textAlign: align,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
    );

    return _wrapWithAction(widget, c.action, onAction);
  });
}

// =============================================================================
// card
// =============================================================================

Widget _buildCard(
  BduiComponent c,
  List<Widget> children,
  void Function(BduiAction)? onAction,
) {
  final title = c.stringProp('title');
  final subtitle = c.stringProp('subtitle');
  final iconName = c.stringProp('icon');
  final colorHex = c.stringProp('color');
  final badgeCount = c.intProp('badge');
  final elevated = c.boolProp('elevated', fallback: true);

  return Builder(builder: (context) {
    final color = colorHex != null ? _parseColor(colorHex) : null;

    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (iconName != null) ...[
            Icon(_resolveIcon(iconName), size: 32, color: color),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                if (subtitle != null)
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          if (badgeCount != null && badgeCount > 0)
            Badge(
              label: Text('$badgeCount'),
              child: const SizedBox(width: 24, height: 24),
            ),
          ...children,
        ],
      ),
    );

    final card = Card(
      elevation: elevated ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: elevated
            ? BorderSide.none
            : BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: c.action != null && onAction != null
          ? InkWell(
              onTap: () => onAction(c.action!),
              borderRadius: BorderRadius.circular(12),
              child: content,
            )
          : content,
    );

    return card;
  });
}

// =============================================================================
// list
// =============================================================================

Widget _buildList(
  BduiComponent c,
  List<Widget> children,
  void Function(BduiAction)? onAction,
) {
  final title = c.stringProp('title');
  final emptyText = c.stringPropOr('empty_text', '');
  final showDivider = c.boolProp('divider');

  return Builder(builder: (context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
        if (children.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child:
                  Text(emptyText, style: Theme.of(context).textTheme.bodySmall),
            ),
          )
        else
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (showDivider && i < children.length - 1)
              const Divider(height: 1),
          ],
      ],
    );
  });
}

// =============================================================================
// list_tile
// =============================================================================

Widget _buildListTile(
  BduiComponent c,
  List<Widget> children,
  void Function(BduiAction)? onAction,
) {
  final title = c.stringPropOr('title', '');
  final subtitle = c.stringProp('subtitle');
  final leadingIcon = c.stringProp('leading_icon');
  final trailingText = c.stringProp('trailing_text');

  return ListTile(
    contentPadding: EdgeInsets.zero,
    leading: leadingIcon != null ? Icon(_resolveIcon(leadingIcon)) : null,
    title: Text(title),
    subtitle: subtitle != null ? Text(subtitle) : null,
    trailing: trailingText != null
        ? Text(trailingText, style: const TextStyle(fontSize: 12))
        : null,
    onTap: c.action != null && onAction != null
        ? () => onAction(c.action!)
        : null,
  );
}

// =============================================================================
// scroll_view
// =============================================================================

Widget _buildScrollView(
  BduiComponent c,
  List<Widget> children,
  void Function(BduiAction)? onAction,
) {
  final padding = c.doublePropOr('padding', 16);

  return SingleChildScrollView(
    padding: EdgeInsets.all(padding),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    ),
  );
}

// =============================================================================
// button
// =============================================================================

Widget _buildButton(
  BduiComponent c,
  List<Widget> children,
  void Function(BduiAction)? onAction,
) {
  final text = c.stringPropOr('text', '');
  final variant = c.stringPropOr('style', 'filled');
  final iconName = c.stringProp('icon');
  final fullWidth = c.boolProp('full_width');

  final onPressed =
      c.action != null && onAction != null ? () => onAction(c.action!) : null;
  final icon = iconName != null ? Icon(_resolveIcon(iconName)) : null;

  Widget button;
  switch (variant) {
    case 'outlined':
      button = icon != null
          ? OutlinedButton.icon(
              onPressed: onPressed, icon: icon, label: Text(text))
          : OutlinedButton(onPressed: onPressed, child: Text(text));
    case 'text':
      button = icon != null
          ? TextButton.icon(
              onPressed: onPressed, icon: icon, label: Text(text))
          : TextButton(onPressed: onPressed, child: Text(text));
    default: // filled
      button = icon != null
          ? ElevatedButton.icon(
              onPressed: onPressed, icon: icon, label: Text(text))
          : ElevatedButton(onPressed: onPressed, child: Text(text));
  }

  if (fullWidth) {
    return SizedBox(width: double.infinity, child: button);
  }
  return button;
}

// =============================================================================
// image
// =============================================================================

Widget _buildImage(
  BduiComponent c,
  List<Widget> children,
  void Function(BduiAction)? onAction,
) {
  final url = c.stringProp('url');
  if (url == null) return const SizedBox.shrink();

  final width = c.doubleProp('width');
  final height = c.doubleProp('height');
  final fit = _parseBoxFit(c.stringProp('fit'));

  final widget = Image.network(
    url,
    width: width,
    height: height,
    fit: fit,
    errorBuilder: (_, __, ___) => SizedBox(
      width: width,
      height: height,
      child: const Center(child: Icon(Icons.broken_image, size: 32)),
    ),
  );

  return _wrapWithAction(widget, c.action, onAction);
}

// =============================================================================
// spacer
// =============================================================================

Widget _buildSpacer(
  BduiComponent c,
  List<Widget> children,
  void Function(BduiAction)? onAction,
) {
  return SizedBox(
    height: c.doublePropOr('height', 16),
    width: c.doubleProp('width'),
  );
}

// =============================================================================
// divider
// =============================================================================

Widget _buildDivider(
  BduiComponent c,
  List<Widget> children,
  void Function(BduiAction)? onAction,
) {
  return Divider(
    indent: c.doublePropOr('indent', 0),
    endIndent: c.doublePropOr('indent', 0),
  );
}

// =============================================================================
// row
// =============================================================================

Widget _buildRow(
  BduiComponent c,
  List<Widget> children,
  void Function(BduiAction)? onAction,
) {
  final spacing = c.doublePropOr('spacing', 0);

  final spacedChildren = <Widget>[];
  for (int i = 0; i < children.length; i++) {
    spacedChildren.add(Expanded(child: children[i]));
    if (spacing > 0 && i < children.length - 1) {
      spacedChildren.add(SizedBox(width: spacing));
    }
  }

  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: spacedChildren,
  );
}

// =============================================================================
// container
// =============================================================================

Widget _buildContainer(
  BduiComponent c,
  List<Widget> children,
  void Function(BduiAction)? onAction,
) {
  final padding = c.doubleProp('padding');
  final colorHex = c.stringProp('color');
  final borderRadius = c.doublePropOr('border_radius', 0);

  final widget = Container(
    padding: padding != null ? EdgeInsets.all(padding) : null,
    decoration: BoxDecoration(
      color: colorHex != null ? _parseColor(colorHex) : null,
      borderRadius:
          borderRadius > 0 ? BorderRadius.circular(borderRadius) : null,
    ),
    child: children.length == 1
        ? children.first
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
  );

  return _wrapWithAction(widget, c.action, onAction);
}

// =============================================================================
// icon
// =============================================================================

Widget _buildIcon(
  BduiComponent c,
  List<Widget> children,
  void Function(BduiAction)? onAction,
) {
  final name = c.stringPropOr('name', 'help_outline');
  final size = c.doublePropOr('size', 24);
  final colorHex = c.stringProp('color');

  final widget = Icon(
    _resolveIcon(name),
    size: size,
    color: colorHex != null ? _parseColor(colorHex) : null,
  );

  return _wrapWithAction(widget, c.action, onAction);
}

// =============================================================================
// badge
// =============================================================================

Widget _buildBadge(
  BduiComponent c,
  List<Widget> children,
  void Function(BduiAction)? onAction,
) {
  final count = c.intPropOr('count', 0);
  final colorHex = c.stringProp('color');

  return Badge(
    label: Text('$count'),
    backgroundColor: colorHex != null ? _parseColor(colorHex) : null,
    child: children.isNotEmpty ? children.first : null,
  );
}

// =============================================================================
// Утилиты
// =============================================================================

/// Оборачивает виджет в GestureDetector если есть action.
Widget _wrapWithAction(
  Widget widget,
  BduiAction? action,
  void Function(BduiAction)? onAction,
) {
  if (action != null && onAction != null) {
    return GestureDetector(
      onTap: () => onAction(action),
      child: widget,
    );
  }
  return widget;
}

/// Парсинг HEX-цвета (#RRGGBB или #AARRGGBB).
Color _parseColor(String hex) {
  final buffer = StringBuffer();
  final cleaned = hex.replaceFirst('#', '');
  if (cleaned.length == 6) buffer.write('FF');
  buffer.write(cleaned);
  return Color(int.parse(buffer.toString(), radix: 16));
}

/// Маппинг строкового стиля → TextStyle из темы.
TextStyle? _resolveTextStyle(BuildContext context, String? styleName) {
  final theme = Theme.of(context).textTheme;
  return switch (styleName) {
    'headline' => theme.headlineSmall,
    'title' => theme.titleMedium,
    'body' => theme.bodyMedium,
    'caption' => theme.bodySmall,
    'label' => theme.labelMedium,
    'tip' => theme.bodyMedium?.copyWith(
      fontStyle: FontStyle.italic,
      color: const Color(0xFF5D4037),
    ),
    _ => theme.bodyMedium,
  };
}

TextAlign? _parseTextAlign(String? value) => switch (value) {
      'center' => TextAlign.center,
      'right' => TextAlign.right,
      'left' => TextAlign.left,
      _ => null,
    };

BoxFit _parseBoxFit(String? value) => switch (value) {
      'cover' => BoxFit.cover,
      'contain' => BoxFit.contain,
      'fill' => BoxFit.fill,
      'none' => BoxFit.none,
      _ => BoxFit.cover,
    };

/// Маппинг строковых имён → IconData. Покрывает иконки, используемые в CoachLink.
IconData _resolveIcon(String name) => _iconMap[name] ?? Icons.help_outline;

const _iconMap = <String, IconData>{
  'home': Icons.home,
  'people': Icons.people,
  'person': Icons.person,
  'person_add': Icons.person_add,
  'person_search': Icons.person_search,
  'assignment': Icons.assignment,
  'description': Icons.description,
  'check_circle': Icons.check_circle,
  'warning': Icons.warning,
  'warning_amber': Icons.warning_amber,
  'schedule': Icons.schedule,
  'arrow_forward': Icons.arrow_forward,
  'chevron_right': Icons.chevron_right,
  'fitness_center': Icons.fitness_center,
  'directions_run': Icons.directions_run,
  'timer': Icons.timer,
  'favorite': Icons.favorite,
  'trending_up': Icons.trending_up,
  'groups': Icons.groups,
  'sports': Icons.sports,
  'notifications': Icons.notifications,
  'notifications_outlined': Icons.notifications_outlined,
  'star': Icons.star,
  'info': Icons.info,
  'lightbulb': Icons.lightbulb,
  'edit_note': Icons.edit_note,
  'help_outline': Icons.help_outline,
  'broken_image': Icons.broken_image,
};
