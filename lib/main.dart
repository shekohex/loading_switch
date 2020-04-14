import 'package:flutter/material.dart';

void main() => runApp(MyApp());

enum SwitchState { turnedOff, loading, turnedOn }

class Constants {
  static const offColor = Color(0xFFFADDD1);
  static const onColor = Color(0xFF9CF4A7);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Loading Switch',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.blueAccent.shade400,
        ),
        home: MyHomePage(),
      );
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  SwitchState _switchState;
  AnimationController _mainAnimationController;
  AnimationController _textStateAnimationController;
  Animation<double> _textStateAnimation;
  int _textPos;
  // 1 => Up, -1 Down
  int _fadeDir = 1;
  @override
  void initState() {
    super.initState();
    _switchState = SwitchState.turnedOff;
    _mainAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textStateAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _textStateAnimation = CurvedAnimation(
      curve: Curves.easeIn,
      parent: _textStateAnimationController,
    );
    _showStateText();
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _textStateAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _mainAnimationController,
        builder: (context, _) => Container(
          color: ColorTween(
            begin: Constants.offColor,
            end: Constants.onColor,
          ).animate(_mainAnimationController).value,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 105,
                  child: GestureDetector(
                    onTap: _changeSwitchState,
                    child: LoadingSwitch(
                      mainAnimationController: _mainAnimationController,
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: _textStateAnimation,
                  child: _buildStateText(context),
                  builder: _buildCurrentStateText,
                )
              ],
            ),
          ),
        ),
      );

  Transform _buildCurrentStateText(BuildContext context, Widget child) {
    final dy = 25 * _textPos * _fadeDir * (1 - _textStateAnimation.value);
    return Transform.translate(
      offset: Offset(0, dy),
      child: Opacity(
        opacity: _textStateAnimation.value,
        child: child,
      ),
    );
  }

  void _showStateText() {
    setState(() => _textPos = 1);
    _textStateAnimationController.forward();
  }

  void _hideStateText() {
    setState(() => _textPos = -1);
    _textStateAnimationController.reverse();
  }

  Widget _buildStateText(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    switch (_switchState) {
      case SwitchState.turnedOff:
        return Text(
          'Devices Off',
          style: textTheme.display1.copyWith(
            fontWeight: FontWeight.w500,
          ),
        );
        break;
      case SwitchState.loading:
        return Text(
          'Please Wait ...',
          style: textTheme.display1.copyWith(
            fontWeight: FontWeight.w500,
          ),
        );
        break;
      case SwitchState.turnedOn:
        return Text(
          'Devices On',
          style: textTheme.display1.copyWith(
            fontWeight: FontWeight.w500,
          ),
        );
        break;
      default:
        return Text(
          'Unknown State',
          style: textTheme.display1.copyWith(
            fontWeight: FontWeight.w500,
          ),
        );
    }
  }

  Future<void> _changeSwitchState() async {
    if (_switchState == SwitchState.turnedOff) {
      await _turnSwitchOn();
    } else if (_switchState == SwitchState.turnedOn) {
      await _turnSwitchOff();
    } else {
      // DO NOTHING!
    }
  }

  Future<void> _turnSwitchOff() async {
    _fadeDir = -1;
    _hideStateText();
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _switchState = SwitchState.loading;
    _mainAnimationController.animateTo(0.5);
    _showStateText();
    await Future<void>.delayed(const Duration(seconds: 2));
    _hideStateText();
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _switchState = SwitchState.turnedOff;
    _mainAnimationController.reverse(from: 0.5);
    _showStateText();
  }

  Future<void> _turnSwitchOn() async {
    _fadeDir = 1;
    _hideStateText();
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _switchState = SwitchState.loading;
    _mainAnimationController.animateTo(0.5);
    _showStateText();
    await Future<void>.delayed(const Duration(seconds: 2));
    _hideStateText();
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _switchState = SwitchState.turnedOn;
    _mainAnimationController.animateTo(1);
    _showStateText();
  }
}

class LoadingSwitch extends StatelessWidget {
  const LoadingSwitch({
    @required AnimationController mainAnimationController,
    Key key,
  })  : _mainAnimationController = mainAnimationController,
        super(key: key);

  final AnimationController _mainAnimationController;

  @override
  Widget build(BuildContext context) => Stack(
        alignment: AlignmentGeometryTween(
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
        ).animate(_mainAnimationController).value,
        children: [
          Container(
            height: 60,
            width: 60,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: ColorTween(
                begin: Colors.redAccent,
                end: Colors.greenAccent,
              ).animate(_mainAnimationController).value,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const CircularProgressIndicator(
              strokeWidth: 10,
            ),
          ),
          Container(
            width: IntTween(
              begin: 100,
              end: -100,
            ).animate(_mainAnimationController).value.abs().toDouble(),
            height: 60,
            decoration: BoxDecoration(
              color: ColorTween(
                begin: Colors.redAccent,
                end: Colors.greenAccent,
              ).animate(_mainAnimationController).value,
              borderRadius: BorderRadius.circular(60),
              boxShadow: [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 10,
                  spreadRadius: 0.2,
                  offset: const Offset(1.5, 1.5),
                ),
              ],
              border: Border.all(
                color: Colors.black12,
              ),
            ),
          ),
          Transform(
            transform: Matrix4.translationValues(
              _mainAnimationController.value * 2,
              0,
              0,
            ),
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      spreadRadius: 0.5,
                      offset: const Offset(0.9, 0.9),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(50 / 2),
                ),
              ),
            ),
          ),
        ],
      );
}
