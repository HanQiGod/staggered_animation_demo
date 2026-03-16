import 'package:flutter/material.dart';

void main() {
  runApp(const StaggeredShowcaseApp());
}

class StaggeredShowcaseApp extends StatelessWidget {
  const StaggeredShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF20437A),
      brightness: Brightness.light,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter 交错动画示例',
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.transparent,
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: const Color(0xFF11213B),
          displayColor: const Color(0xFF11213B),
        ),
      ),
      home: const StaggeredDemoPage(),
    );
  }
}

class StaggeredDemoPage extends StatefulWidget {
  const StaggeredDemoPage({super.key});

  @override
  State<StaggeredDemoPage> createState() => _StaggeredDemoPageState();
}

class _StaggeredDemoPageState extends State<StaggeredDemoPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isPlaying = false;

  static const _animationDuration = Duration(milliseconds: 2000);

  static const _timelineSegments =
      <({String title, String range, String detail})>[
        (title: '淡入', range: '0% - 10%', detail: '透明度从 0 到 1，建立视觉起点'),
        (title: '间隙', range: '10% - 12.5%', detail: '短暂停顿，给下一段留出节奏感'),
        (title: '变宽', range: '12.5% - 25%', detail: '宽度从 50 增长到 150'),
        (title: '上移 + 变高', range: '25% - 37.5%', detail: '底部内边距和高度同时变化'),
        (title: '变圆', range: '37.5% - 50%', detail: '圆角从 4 过渡到 75'),
        (title: '变色', range: '50% - 75%', detail: '从蓝色渐变为橙色'),
        (title: '保持', range: '75% - 100%', detail: '停在终点，随后自动反向'),
      ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _playAnimation() async {
    if (_isPlaying) {
      return;
    }

    setState(() {
      _isPlaying = true;
    });

    try {
      await _controller.forward(from: 0).orCancel;
      await _controller.reverse().orCancel;
    } on TickerCanceled {
      // 控制器销毁时结束等待，不需要额外处理。
    } finally {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              Color(0xFFF4F8FF),
              Color(0xFFE8F0FF),
              Color(0xFFF9F4EC),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final stageWidth = constraints.maxWidth < 640
                  ? constraints.maxWidth - 48
                  : 400.0;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '一个控制器，多个动画',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '当前项目原本只有 Flutter 模板计数器。我把它改成了文章里的经典交错动画案例：点击舞台后，同一个控制器会依次驱动淡入、变宽、上移增高、变圆和变色，并在播放结束后自动反向恢复。',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.6,
                            color: const Color(0xFF2D4265),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Wrap(
                          spacing: 24,
                          runSpacing: 24,
                          alignment: WrapAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              width: 320,
                              child: _ArticleMappingCard(
                                animationDuration: _animationDuration,
                              ),
                            ),
                            SizedBox(
                              width: stageWidth.clamp(280.0, 400.0).toDouble(),
                              child: _DemoStageCard(
                                controller: _controller.view,
                                isPlaying: _isPlaying,
                                onTap: _playAnimation,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Text(
                          '时间轴切片',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _timelineSegments
                              .map(
                                (segment) => _TimelineSegmentCard(
                                  title: segment.title,
                                  range: segment.range,
                                  detail: segment.detail,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ArticleMappingCard extends StatelessWidget {
  const _ArticleMappingCard({required this.animationDuration});

  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFCFD8EA)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x140E2248),
            blurRadius: 28,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '项目分析',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '工程结构非常轻量，只有一个入口文件和默认测试，因此最合适的做法不是继续拆复杂模块，而是直接把文章里的示例落在主页上，保留 demo 可读性。',
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
            ),
            const SizedBox(height: 20),
            const _MappingPoint(
              title: '控制器',
              content: '单个 AnimationController，统一控制总时长。',
            ),
            const _MappingPoint(
              title: '时间窗口',
              content: '每个属性各自使用 Interval 裁剪时间轴。',
            ),
            const _MappingPoint(
              title: '属性变化',
              content: '透明度、尺寸、位移、圆角、颜色全部通过 Tween 驱动。',
            ),
            _MappingPoint(
              title: '总时长',
              content: '${animationDuration.inMilliseconds}ms，正向播放后自动反向。',
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F6FD),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '示例交互：点击右侧舞台或按钮即可重播整段交错动画。',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF445B80),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MappingPoint extends StatelessWidget {
  const _MappingPoint({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFEB8C39),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                children: <InlineSpan>[
                  TextSpan(
                    text: '$title：',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: content),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoStageCard extends StatelessWidget {
  const _DemoStageCard({
    required this.controller,
    required this.isPlaying,
    required this.onTap,
  });

  final Animation<double> controller;
  final bool isPlaying;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF0E1D37),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x24142640),
            blurRadius: 30,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  '交错动画舞台',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                AnimatedBuilder(
                  animation: controller,
                  builder: (BuildContext context, Widget? child) {
                    return Text(
                      '${(controller.value * 100).round()}%',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: const Color(0xFFB7C8F1),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              '点击舞台播放交错动画',
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF92A8CC),
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              key: const Key('stagger-demo-stage'),
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: Container(
                height: 320,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: <Color>[Color(0xFF0F2648), Color(0xFF102C56)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: const Color(0xFF2B456D)),
                ),
                child: Column(
                  children: <Widget>[
                    AnimatedBuilder(
                      animation: controller,
                      builder: (BuildContext context, Widget? child) {
                        return LinearProgressIndicator(
                          key: const Key('stagger-demo-progress'),
                          value: controller.value,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(999),
                          backgroundColor: const Color(0xFF18335B),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFF4A24E),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF132746),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: const Color(0xFF32517C)),
                        ),
                        child: StaggerAnimation(controller: controller),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onTap,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFFF0A04B),
                  foregroundColor: const Color(0xFF1A2740),
                ),
                icon: Icon(isPlaying ? Icons.hourglass_top : Icons.play_arrow),
                label: Text(isPlaying ? '播放中...' : '播放一次'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StaggerAnimation extends StatelessWidget {
  StaggerAnimation({super.key, required this.controller})
    : opacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.0, 0.1, curve: Curves.easeOut),
        ),
      ),
      width = Tween<double>(begin: 50, end: 150).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.125, 0.25, curve: Curves.easeInOutCubic),
        ),
      ),
      height = Tween<double>(begin: 50, end: 100).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.25, 0.375, curve: Curves.easeInOutCubic),
        ),
      ),
      bottomInset = Tween<double>(begin: 0, end: 80).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.25, 0.375, curve: Curves.easeInOutCubic),
        ),
      ),
      borderRadius =
          BorderRadiusTween(
            begin: BorderRadius.circular(4),
            end: BorderRadius.circular(75),
          ).animate(
            CurvedAnimation(
              parent: controller,
              curve: const Interval(0.375, 0.5, curve: Curves.easeInOut),
            ),
          ),
      color =
          ColorTween(
            begin: const Color(0xFF2D6CE0),
            end: const Color(0xFFF39A45),
          ).animate(
            CurvedAnimation(
              parent: controller,
              curve: const Interval(0.5, 0.75, curve: Curves.easeInOutCubic),
            ),
          );

  final Animation<double> controller;
  final Animation<double> opacity;
  final Animation<double> width;
  final Animation<double> height;
  final Animation<double> bottomInset;
  final Animation<BorderRadius?> borderRadius;
  final Animation<Color?> color;

  Widget _buildAnimation(BuildContext context, Widget? child) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset.value),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Opacity(
          key: const Key('stagger-demo-opacity'),
          opacity: opacity.value,
          child: Container(
            key: const Key('stagger-demo-box'),
            width: width.value,
            height: height.value,
            decoration: BoxDecoration(
              color: color.value ?? const Color(0xFF2D6CE0),
              border: Border.all(color: const Color(0xFF7F90EC), width: 3),
              borderRadius:
                  borderRadius.value ??
                  const BorderRadius.all(Radius.circular(4)),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x292D6CE0),
                  blurRadius: 18,
                  offset: Offset(0, 10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: controller, builder: _buildAnimation);
  }
}

class _TimelineSegmentCard extends StatelessWidget {
  const _TimelineSegmentCard({
    required this.title,
    required this.range,
    required this.detail,
  });

  final String title;
  final String range;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 180,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFD3DCEB)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                range,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: const Color(0xFF3365A5),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                detail,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF475D80),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
