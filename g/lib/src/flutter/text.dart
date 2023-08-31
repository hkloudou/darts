// import 'package:auto_size_text_pk/auto_size_text_pk.dart';
import 'package:flutter/material.dart';
import 'package:g/src/extensions/string_ext.dart';
import 'package:g/src/flutter/mixins/color_mixin.dart';
import 'package:g/src/flutter/mixins/render_mixin.dart';
import 'package:auto_size_text_pk/auto_size_text_pk.dart';
import 'package:g/src/gg.dart';

import 'builder.dart';
// import 'nothing.dart';
// import 'velocityx_mixins/color_mixin.dart';

@protected
class GTextBuilder extends GWidgetBuilder<Widget>
    with GColorMixin<GTextBuilder>, GRenderMixin<GTextBuilder> {
  GTextBuilder(String this._text) {
    setChildToColor(this);
    setChildForRender(this);
  }

  GTextBuilder.existing(String this._text, this._textStyle) {
    setChildToColor(this);
  }

  String? _text, _fontFamily;

  double? _scaleFactor,
      _fontSize,
      _minFontSize,
      _letterSpacing,
      _lineHeight,
      _maxFontSize,
      _stepGranularity,
      _wordSpacing;
  int? _maxLines;
  FontWeight? _fontWeight;
  TextAlign? _textAlign;
  FontStyle? _fontStyle;
  TextDecoration? _decoration;
  TextStyle? _textStyle, _themedStyle;
  StrutStyle? _strutStyle;
  TextOverflow? _overflow;
  TextBaseline? _textBaseline;
  Widget? _replacement;
  bool? _softWrap, _wrapWords;
  double _shadowBlur = 0.0;
  Color _shadowColor = const Color(0xFF000000);
  Offset _shadowOffset = Offset.zero;

  bool _isIntrinsic = false;

  /// The text to display.
  ///
  /// This will be null if a [textSpan] is provided instead.
  GTextBuilder text(String text) {
    _text = text;
    return this;
  }

  /// Set [color] of the text
  GTextBuilder color(Color? color) {
    velocityColor = color;
    return this;
  }

  /// Set [color] of the text using hexvalue
  GTextBuilder hexColor(String colorHex) =>
      this..velocityColor = G.hexToColor(colorHex);

  /// [LayoutBuilder] does not support using IntrinsicWidth or IntrinsicHeight.
  ///
  /// Note: Use it only for few widgets like [DataTable], [IntrinsicWidth] or
  /// [IntrinsicHeight] etc which doesn't work well with Vx
  /// but using [isIntrinsic] will disable [AutoSizeText].
  GTextBuilder get isIntrinsic => this.._isIntrinsic = true;

  /// An optional maximum number of lines for the text to span, wrapping if necessary.
  /// If the text exceeds the given number of lines, it will be resized according
  /// to the specified bounds and if necessary truncated according to [overflow].
  ///
  /// If this is 1, text will not wrap. Otherwise, text will be wrapped at the
  /// edge of the box.
  ///
  /// If this is null, but there is an ambient [DefaultTextStyle] that specifies
  /// an explicit number for its [DefaultTextStyle.maxLines], then the
  /// [DefaultTextStyle] value will take precedence. You can use a [RichText]
  /// widget directly to entirely override the [DefaultTextStyle].
  GTextBuilder maxLines(int lines) {
    _maxLines = lines;
    return this;
  }

  /// Set [fontFamily] for the text
  GTextBuilder fontFamily(String family) {
    _fontFamily = family;
    return this;
  }

  /// Whether the text should break at soft line breaks.
  ///
  /// If false, the glyphs in the text will be positioned as if there was
  /// unlimited horizontal space.
  GTextBuilder softWrap(bool softWrap) {
    _softWrap = softWrap;
    return this;
  }

  /// Whether words which don't fit in one line should be wrapped.
  ///
  /// If false, the fontSize is lowered as far as possible until all words fit
  /// into a single line.
  GTextBuilder wrapWords(bool wrapWords) {
    _wrapWords = wrapWords;
    return this;
  }

  /// The common baseline that should be aligned between this text span and its
  /// parent text span, or, for the root text spans, with the line box.
  GTextBuilder textBaseLine(TextBaseline baseline) {
    _textBaseline = baseline;
    return this;
  }

  /// The amount of space (in logical pixels) to add at each sequence of
  /// white-space (i.e. between each word). A negative value can be used to
  /// bring the words closer.
  GTextBuilder wordSpacing(double spacing) {
    _wordSpacing = spacing;
    return this;
  }

  /// Can be used to set overflow of a text.
  /// How visual overflow should be handled.
  GTextBuilder overflow(TextOverflow overflow) {
    _overflow = overflow;
    return this;
  }

  ///
  /// The minimum text size constraint to be used when auto-sizing text.
  ///
  GTextBuilder minFontSize(double minFontSize) {
    _minFontSize = minFontSize;
    return this;
  }

  ///
  ///  The maximum text size constraint to be used when auto-sizing text.
  ///
  GTextBuilder maxFontSize(double maxFontSize) {
    _maxFontSize = maxFontSize;
    return this;
  }

  /// The step size in which the font size is being adapted to constraints.
  ///
  /// The Text scales uniformly in a range between [minFontSize] and
  /// [maxFontSize].
  /// Each increment occurs as per the step size set in stepGranularity.
  ///
  /// Most of the time you don't want a stepGranularity below 1.0.
  ///
  GTextBuilder stepGranularity(double stepGranularity) {
    _stepGranularity = stepGranularity;
    return this;
  }

  /// If the text is overflowing and does not fit its bounds, this widget is
  /// displayed instead.
  GTextBuilder overflowReplacement(Widget overflowReplacement) {
    _replacement = overflowReplacement;
    return this;
  }

  /// Set [FontWeight] for the text
  GTextBuilder fontWeight(FontWeight weight) {
    _fontWeight = weight;
    return this;
  }

  /// Use textStyle to provide custom or any theme style.
  ///
  /// If the style's 'inherit' property is true, the style will be merged with
  /// the closest enclosing [DefaultTextStyle]. Otherwise, the style will
  /// replace the closest enclosing [DefaultTextStyle].
  GTextBuilder textStyle(TextStyle? style) {
    _themedStyle = style;
    return this;
  }

  /// The strut style to use. Strut style defines the strut, which sets minimum
  /// vertical layout metrics.
  ///
  /// Omitting or providing null will disable strut.
  ///
  /// Omitting or providing null for any properties of [StrutStyle] will result in
  /// default values being used. It is highly recommended to at least specify a
  /// font size.
  ///
  /// See [StrutStyle] for details.
  GTextBuilder strutStyle(StrutStyle? style) {
    _strutStyle = style;
    return this;
  }

  // Give custom text alignment
  GTextBuilder align(TextAlign align) => this.._textAlign = align;

  /// How the text should be aligned horizontally.
  ///
  /// To align text in [center]
  GTextBuilder get center => this.._textAlign = TextAlign.center;

  /// To align text in [start]
  GTextBuilder get start => this.._textAlign = TextAlign.start;

  /// To align text in [end]
  GTextBuilder get end => this.._textAlign = TextAlign.end;

  /// To align text as [justify]
  GTextBuilder get justify => this.._textAlign = TextAlign.justify;

  /// To overlow text as [fade]
  GTextBuilder get fade => this.._overflow = TextOverflow.fade;

  /// To overlow text as [ellipsis]
  GTextBuilder get ellipsis => this.._overflow = TextOverflow.ellipsis;

  /// To overlow text as [visible]
  GTextBuilder get visible => this.._overflow = TextOverflow.visible;

  /// To set fontSize of the text using [size]
  GTextBuilder size(double? size) => this.._fontSize = size;

  /// Sets [TextTheme] headline 1
  GTextBuilder headline1(BuildContext context) {
    _themedStyle = Theme.of(context).textTheme.displayLarge;
    return this;
  }

  /// Sets [TextTheme] headline 2
  GTextBuilder headline2(BuildContext context) {
    _themedStyle = Theme.of(context).textTheme.displayMedium;
    return this;
  }

  /// Sets [TextTheme] headline 3
  GTextBuilder headline3(BuildContext context) {
    _themedStyle = Theme.of(context).textTheme.displaySmall;
    return this;
  }

  /// Sets [TextTheme] headline 4
  GTextBuilder headline4(BuildContext context) {
    _themedStyle = Theme.of(context).textTheme.headlineMedium;
    return this;
  }

  /// Sets [TextTheme] headline 5
  GTextBuilder headline5(BuildContext context) {
    _themedStyle = Theme.of(context).textTheme.headlineSmall;
    return this;
  }

  /// Sets [TextTheme] headline 6
  GTextBuilder headline6(BuildContext context) {
    _themedStyle = Theme.of(context).textTheme.titleLarge;
    return this;
  }

  /// Sets [TextTheme] bodyText1
  GTextBuilder bodyText1(BuildContext context) {
    _themedStyle = Theme.of(context).textTheme.bodyLarge;
    return this;
  }

  /// Sets [TextTheme] bodyText2
  GTextBuilder bodyText2(BuildContext context) {
    _themedStyle = Theme.of(context).textTheme.bodyMedium;
    return this;
  }

  /// Sets [TextTheme] caption
  GTextBuilder caption(BuildContext context) {
    _themedStyle = Theme.of(context).textTheme.bodySmall;
    return this;
  }

  /// Sets [TextTheme] subtitle1
  GTextBuilder subtitle1(BuildContext context) {
    _themedStyle = Theme.of(context).textTheme.titleMedium;
    return this;
  }

  /// Sets [TextTheme] subtitle2
  GTextBuilder subtitle2(BuildContext context) {
    _themedStyle = Theme.of(context).textTheme.titleSmall;
    return this;
  }

  /// Sets [TextTheme] overline
  GTextBuilder overlineText(BuildContext context) {
    _themedStyle = Theme.of(context).textTheme.labelSmall;
    return this;
  }

  /// Sets [TextTheme] button
  GTextBuilder buttonText(BuildContext context) {
    _themedStyle = Theme.of(context).textTheme.labelLarge;
    return this;
  }

  /// Sets [textScaleFactor] to extra small i.e. 0.75
  GTextBuilder get xs => _fontSizedText(child: this, scaleFactor: 0.75);

  /// Sets [textScaleFactor] to small i.e. 0.875
  GTextBuilder get sm => _fontSizedText(child: this, scaleFactor: 0.875);

  /// Sets [textScaleFactor] to base i.e. 1 or default
  GTextBuilder get base => _fontSizedText(child: this, scaleFactor: 1);

  /// Sets [textScaleFactor] to large i.e. 1.125
  GTextBuilder get lg => _fontSizedText(child: this, scaleFactor: 1.125);

  /// Sets [textScaleFactor] to extra large i.e. 1.25
  GTextBuilder get xl => _fontSizedText(child: this, scaleFactor: 1.25);

  /// Sets [textScaleFactor] to twice extra large i.e. 1.5
  GTextBuilder get xl2 => _fontSizedText(child: this, scaleFactor: 1.5);

  /// Sets [textScaleFactor] to thrice extra large i.e. 1.875
  GTextBuilder get xl3 => _fontSizedText(child: this, scaleFactor: 1.875);

  /// Sets [textScaleFactor] to four times extra large i.e. 2.25
  GTextBuilder get xl4 => _fontSizedText(child: this, scaleFactor: 2.25);

  /// Sets [textScaleFactor] to five times extra large i.e. 3
  GTextBuilder get xl5 => _fontSizedText(child: this, scaleFactor: 3);

  /// Sets [textScaleFactor] to six times extra large i.e. 4
  GTextBuilder get xl6 => _fontSizedText(child: this, scaleFactor: 4);

  /// Sets [textScaleFactor] to custom value
  GTextBuilder scale(double value) =>
      _fontSizedText(child: this, scaleFactor: value);

  GTextBuilder _fontSizedText(
      {required double scaleFactor, required GTextBuilder child}) {
    _fontSize = _fontSize ?? 14.0;
    _scaleFactor = scaleFactor;
    return this;
  }

  /// Sets [FontWeight] to [FontWeight.w100]
  GTextBuilder get hairLine => _fontWeightedText(weight: FontWeight.w100);

  /// Sets [FontWeight] to [FontWeight.w200]
  GTextBuilder get thin => _fontWeightedText(weight: FontWeight.w200);

  /// Sets [FontWeight] to [FontWeight.w300]
  GTextBuilder get light => _fontWeightedText(weight: FontWeight.w300);

  /// Sets [FontWeight] to [FontWeight.w400]
  GTextBuilder get normal => _fontWeightedText(weight: FontWeight.w400);

  /// Sets [FontWeight] to [FontWeight.w500]
  GTextBuilder get medium => _fontWeightedText(weight: FontWeight.w500);

  /// Sets [FontWeight] to [FontWeight.w600]
  GTextBuilder get semiBold => _fontWeightedText(weight: FontWeight.w600);

  /// Sets [FontWeight] to [FontWeight.w700]
  GTextBuilder get bold => _fontWeightedText(weight: FontWeight.w700);

  /// Sets [FontWeight] to [FontWeight.w800]
  GTextBuilder get extraBold => _fontWeightedText(weight: FontWeight.w800);

  /// Sets [FontWeight] to [FontWeight.w900]
  GTextBuilder get extraBlack => _fontWeightedText(weight: FontWeight.w900);

  GTextBuilder _fontWeightedText({required FontWeight weight}) {
    _fontWeight = weight;
    return this;
  }

  /// Sets [FontStyle] to [FontStyle.italic]
  GTextBuilder get italic => this.._fontStyle = FontStyle.italic;

  /// Sets [letterSpacing] to -3.0
  GTextBuilder get tightest => this.._letterSpacing = -3.0;

  /// Sets [letterSpacing] to -2.0
  GTextBuilder get tighter => this.._letterSpacing = -2.0;

  /// Sets [letterSpacing] to -1.0
  GTextBuilder get tight => this.._letterSpacing = -1.0;

  /// Sets [letterSpacing] to 1.0
  GTextBuilder get wide => this.._letterSpacing = 1.0;

  /// Sets [letterSpacing] to 2.0
  GTextBuilder get wider => this.._letterSpacing = 2.0;

  /// Sets [letterSpacing] to 3.0
  GTextBuilder get widest => this.._letterSpacing = 3.0;

  /// Sets custom [letterSpacing] with [val]
  GTextBuilder letterSpacing(double val) => this.._letterSpacing = val;

  /// Sets [TextDecoration] as [TextDecoration.underline]
  GTextBuilder get underline => this.._decoration = TextDecoration.underline;

  /// Sets [TextDecoration] as [TextDecoration.lineThrough]
  GTextBuilder get lineThrough =>
      this.._decoration = TextDecoration.lineThrough;

  /// Sets [TextDecoration] as [TextDecoration.overline]
  GTextBuilder get overline => this.._decoration = TextDecoration.overline;

  /// Converts the text to fully uppercase.
  GTextBuilder get uppercase => this.._text = _text!.toUpperCase();

  /// Converts the text to fully lowercase.
  GTextBuilder get lowercase => this.._text = _text!.toLowerCase();

  ///TODO: Converts the text to first letter of very word as uppercase.
  // GTextBuilder get capitalize =>
  //     this.._text = _text!.trim().allWordsCapitilize();

  ///Converts the text to partially hideen text. Best for sensitive data.
  GTextBuilder get hidePartial => this.._text = _text!.hidePartial();

  /// Sets [lineHeight] to 0.75
  GTextBuilder get heightTight => this.._lineHeight = 0.75;

  /// Sets [lineHeight] to 0.875
  GTextBuilder get heightSnug => this.._lineHeight = 0.875;

  /// Sets [lineHeight] to 1.25
  GTextBuilder get heightRelaxed => this.._lineHeight = 1.25;

  /// Sets [lineHeight] to 1.5
  GTextBuilder get heightLoose => this.._lineHeight = 1.5;

  /// Sets custom [lineHeight] with [val]
  GTextBuilder lineHeight(double val) => this.._lineHeight = val;

  /// Sets [Shadow] as specified in request *#127*
  GTextBuilder shadow(
          double offsetX, double offsetY, double blurRadius, Color color) =>
      this
        .._shadowBlur = blurRadius
        .._shadowColor = color
        .._shadowOffset = Offset(offsetX, offsetY);

  /// Sets [Shadow] blur
  GTextBuilder shadowBlur(double blur) => this.._shadowBlur = blur;

  /// Sets [Shadow] color
  GTextBuilder shadowColor(Color color) => this.._shadowColor = color;

  /// Sets [Shadow] offset
  GTextBuilder shadowOffset(double dx, double dy) =>
      this.._shadowOffset = Offset(dx, dy);

  @override
  Widget make({Key? key}) {
    if (!willRender) {
      return const SizedBox.shrink();
    }
    final sdw = [
      Shadow(
          blurRadius: _shadowBlur, color: _shadowColor, offset: _shadowOffset)
    ];
    final ts = TextStyle(
        color: velocityColor,
        fontSize: _fontSize,
        fontStyle: _fontStyle,
        fontFamily: _fontFamily,
        fontWeight: _fontWeight,
        letterSpacing: _letterSpacing,
        decoration: _decoration,
        height: _lineHeight,
        textBaseline: _textBaseline ?? TextBaseline.alphabetic,
        wordSpacing: _wordSpacing,
        shadows: _shadowBlur > 0 ? sdw : null);

    final textWidget = _isIntrinsic
        ? Text(
            _text!,
            key: key,
            textAlign: _textAlign,
            maxLines: _maxLines,
            textScaleFactor: _scaleFactor,
            style: _themedStyle?.merge(ts) ?? _textStyle?.merge(ts) ?? ts,
            softWrap: _softWrap ?? true,
            overflow: _overflow ?? TextOverflow.clip,
            strutStyle: _strutStyle,
          )
        : AutoSizeText(
            _text!,
            key: key,
            textAlign: _textAlign,
            maxLines: _maxLines,
            textScaleFactor: _scaleFactor,
            style: _themedStyle?.merge(ts) ?? _textStyle?.merge(ts) ?? ts,
            softWrap: _softWrap ?? true,
            minFontSize: _minFontSize ?? 12,
            maxFontSize: _maxFontSize ?? double.infinity,
            stepGranularity: _stepGranularity ?? 1,
            overflowReplacement: _replacement,
            overflow: _overflow ?? TextOverflow.clip,
            strutStyle: _strutStyle,
            wrapWords: _wrapWords ?? true,
          );

    return textWidget;
  }
}

extension GTextExtensions on Text {
  ///
  /// Extension method to directly access [VxTextBuilder] with any widget without wrapping or with dot operator.
  ///
  GTextBuilder get text => GTextBuilder.existing(data ?? "", style);
}
