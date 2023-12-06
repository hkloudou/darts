part of flutter_wise_markdown;

class SubscriptBuilder extends MarkdownElementBuilder {
  static const List<String> _subscripts = [
    '₀',
    '₁',
    '₂',
    '₃',
    '₄',
    '₅',
    '₆',
    '₇',
    '₈',
    '₉'
  ];

  @override
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    // We don't currently have a way to control the vertical alignment of text spans.
    // See https://github.com/flutter/flutter/issues/10906#issuecomment-385723664
    String textContent = element.textContent;
    String text = '';
    for (int i = 0; i < textContent.length; i++) {
      text += _subscripts[int.parse(textContent[i])];
    }
    return SelectableText.rich(TextSpan(text: text));
  }
}

class SubscriptSyntax extends md.InlineSyntax {
  static final _pattern = r'_([0-9]+)';
  SubscriptSyntax() : super(_pattern);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.text('sub', match[1]!));
    return true;
  }
}

class MySyntaxHighlighter extends SyntaxHighlighter {
  final Color color;
  MySyntaxHighlighter(this.color);
  TextSpan format(String source) {
    // print("source");
    // print(source);
    return TextSpan(text: source, style: TextStyle(color: this.color));
  }
}

class MarkDownPage extends StatefulWidget {
  final String content;
  final String title;
  final String url;

  MarkDownPage({
    required this.title,
    required this.content,
    this.url = "",
  });

  @override
  _MarkDownPageState createState() => _MarkDownPageState();
}

class _MarkDownPageState extends State<MarkDownPage> {
  GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();
  late CancelToken _cancelToken;
  late String _con;

  @override
  initState() {
    _con = widget.content;
    super.initState();
    _cancelToken = CancelToken();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if (widget.url.isNotEmpty) {
        _refreshKey.currentState?.show();
      }
    });
  }

  @override
  void deactivate() {
    _cancelToken.cancel();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    EdgeInsets devicePadding = MediaQuery.of(context).padding;
    Widget obj = Markdown(
      // styleSheet: style,
      padding: EdgeInsets.only(
          top: 16, bottom: devicePadding.bottom + 16, left: 16, right: 16),
      selectable: false,
      physics: AlwaysScrollableScrollPhysics(),
      data: _con,
      imageDirectory: widget.url.isNotEmpty
          ? Uri.parse(widget.url).resolve('./').toString()
          : null,
      syntaxHighlighter: MySyntaxHighlighter(Theme.of(context).primaryColor),
      builders: {
        'sub': SubscriptBuilder(),
      },
      bulletBuilder: (index, s) {
        switch (s) {
          case BulletStyle.orderedList:
            return Center(
              child: ClipRRect(
                clipBehavior: Clip.antiAlias,
                child: Container(
                  width: 13,
                  height: 13,
                  color: Theme.of(context).primaryColor,
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      textAlign: TextAlign.right,
                      // style: theme.textTheme.bodyText2,
                      style:
                          (theme.textTheme.bodyText2 ?? TextStyle()).copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            );
          default:
            return Text(
              '•',
              textAlign: TextAlign.center,
              // style: theme.textTheme.bodyText2,
              style: (theme.textTheme.bodyText2 ?? TextStyle()).copyWith(
                color: Theme.of(context).primaryColor,
              ),
            );
        }
      },

      styleSheetTheme: MarkdownStyleSheetBaseTheme.material,
      onTapLink: (String text, String? href, String title) {
        WiseLaunchAdapter.go(context, href!, title.isNotEmpty ? title : text,
            openInBrowser: true);
      },
      extensionSet: md.ExtensionSet(
        md.ExtensionSet.gitHubFlavored.blockSyntaxes,
        [
          md.EmojiSyntax(),
          ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
          SubscriptSyntax()
        ],
      ),
    );
    if (widget.url.isNotEmpty) {
      obj = RefreshIndicator(
        key: _refreshKey,
        // onRefresh: null,
        onRefresh: () => WiseLaunchAdapter.onUrlFetchRequest(
          url: widget.url,
          cancelToken: _cancelToken,
          refreshKey: _refreshKey,
        ).then((value) {
          if (mounted && !_cancelToken.isCancelled) {
            setState(() {
              _con = value;
            });
          }
        }).catchError((err) {
          print("err:: Flutter_Wise_Markdown");
          print(err);
        }),
        child: obj,
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: obj,
    );
  }
}
