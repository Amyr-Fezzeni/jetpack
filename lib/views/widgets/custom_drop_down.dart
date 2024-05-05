import 'package:flutter/material.dart';
import 'package:jetpack/constants/style.dart';
import 'package:jetpack/services/util/ext.dart';
import 'package:jetpack/services/util/language.dart';
import 'package:jetpack/views/widgets/loader.dart';
import 'package:jetpack/views/widgets/popup.dart';

class CustDropDown<T> extends StatefulWidget {
  final List<CustDropdownMenuItem> items;
  final Function onChanged;
  final String hintText;
  final double borderRadius;
  final double maxListHeight;
  final double borderWidth;
  final int defaultSelectedIndex;
  final bool enabled;

  const CustDropDown(
      {super.key,
      required this.items,
      required this.onChanged,
      this.hintText = "",
      this.borderRadius = smallRadius,
      this.borderWidth = 1,
      this.maxListHeight = 100,
      this.defaultSelectedIndex = -1,
      this.enabled = true});

  @override
  State<CustDropDown> createState() => _CustDropDownState();
}

class _CustDropDownState extends State<CustDropDown>
    with WidgetsBindingObserver {
  bool _isOpen = false, _isAnyItemSelected = false, _isReverse = false;
  late OverlayEntry _overlayEntry;
  late RenderBox? _renderBox;
  Widget? _itemSelected;
  late Offset dropDownOffset;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          dropDownOffset = getOffset();
        });
      }
      if (widget.defaultSelectedIndex > -1) {
        if (widget.defaultSelectedIndex < widget.items.length) {
          if (mounted) {
            setState(() {
              _isAnyItemSelected = true;
              _itemSelected = widget.items[widget.defaultSelectedIndex];
              widget.onChanged(widget.items[widget.defaultSelectedIndex].value);
            });
          }
        }
      }
    });
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  void _addOverlay() {
    if (mounted) {
      setState(() {
        _isOpen = true;
      });
    }

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry);
  }

  void _removeOverlay() {
    if (mounted) {
      setState(() {
        _isOpen = false;
      });
      _overlayEntry.remove();
    }
  }

  @override
  dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  OverlayEntry _createOverlayEntry() {
    _renderBox = context.findRenderObject() as RenderBox?;

    var size = _renderBox!.size;

    dropDownOffset = getOffset();

    return OverlayEntry(
        maintainState: false,
        builder: (context) => Align(
              alignment: Alignment.center,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: dropDownOffset,
                child: SizedBox(
                  // color: Colors.red,
                  // height: widget.maxListHeight,
                  width: size.width,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: _isReverse
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 15),
                          constraints: BoxConstraints(
                              maxHeight: widget.maxListHeight,
                              maxWidth: size.width),
                          height: widget.maxListHeight,
                          decoration: BoxDecoration(
                              color: context.bgcolor,
                              boxShadow: defaultShadow,
                              borderRadius:
                                  BorderRadius.circular(widget.borderRadius)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(
                              Radius.circular(widget.borderRadius),
                            ),
                            child: Material(
                              elevation: 0,
                              shadowColor: context.invertedColor.withOpacity(1),
                              color: context.bgcolor,
                              child: ListView(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                children: widget.items
                                    .map((item) => GestureDetector(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                child: item.child,
                                              ),
                                              divider()
                                            ],
                                          ),
                                          onTap: () {
                                            if (mounted) {
                                              setState(() {
                                                _isAnyItemSelected = true;
                                                _itemSelected = item.child;
                                                _removeOverlay();
                                                widget.onChanged(item.value);
                                              });
                                            }
                                          },
                                        ))
                                    .toList(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ));
  }

  Offset getOffset() {
    RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    double y = renderBox!.localToGlobal(Offset.zero).dy;
    double spaceAvailable = _getAvailableSpace(y + renderBox.size.height);
    if (spaceAvailable > widget.maxListHeight) {
      _isReverse = false;
      return Offset(0, renderBox.size.height);
    } else {
      _isReverse = true;
      return Offset(
          0,
          renderBox.size.height -
              (widget.maxListHeight + renderBox.size.height));
    }
  }

  double _getAvailableSpace(double offsetY) {
    double safePaddingTop = MediaQuery.of(context).padding.top;
    double safePaddingBottom = MediaQuery.of(context).padding.bottom;

    double screenHeight =
        MediaQuery.of(context).size.height - safePaddingBottom - safePaddingTop;

    return screenHeight - offsetY;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: widget.enabled
            ? () {
                _isOpen ? _removeOverlay() : _addOverlay();
              }
            : null,
        child: Container(
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 15),
          padding: const EdgeInsets.symmetric(vertical: 5)
              .copyWith(left: 15, right: 10),
          decoration: _getDecoration(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 3,
                child: _isAnyItemSelected
                    ? _itemSelected!
                    : Txt(widget.hintText,
                        color: context.invertedColor.withOpacity(.7)),
              ),
              Flexible(
                flex: 1,
                child: Icon(
                  Icons.arrow_drop_down,
                  color: context.invertedColor.withOpacity(.7),
                  size: 25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Decoration? _getDecoration() {
    if (_isOpen && !_isReverse) {
      return BoxDecoration(
          border: Border.all(color: context.invertedColor.withOpacity(.3)),
          color: context.invertedColor.withOpacity(.05),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(widget.borderRadius),
              topRight: Radius.circular(
                widget.borderRadius,
              )));
    } else if (_isOpen && _isReverse) {
      return BoxDecoration(
          border: Border.all(color: context.invertedColor.withOpacity(.3)),
          color: context.invertedColor.withOpacity(.05),
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(widget.borderRadius),
              bottomRight: Radius.circular(
                widget.borderRadius,
              )));
    } else if (!_isOpen) {
      return BoxDecoration(
          border: Border.all(color: context.invertedColor.withOpacity(0)),
          color: context.invertedColor.withOpacity(.05),
          borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)));
    }
    return null;
  }
}

class CustDropdownMenuItem<T> extends StatelessWidget {
  final T value;
  final Widget child;

  const CustDropdownMenuItem(
      {super.key, required this.value, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class SimpleDropDown extends StatefulWidget {
  final String selectedValue;
  final String hint;
  final List<String> values;
  final Function(String) onChanged;
  const SimpleDropDown(
      {super.key,
      required this.selectedValue,
      required this.values,
      required this.onChanged,
      required this.hint});

  @override
  State<SimpleDropDown> createState() => _SimpleDropDownState();
}

class _SimpleDropDownState extends State<SimpleDropDown> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15).copyWith(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: context.invertedColor.withOpacity(.05),
        borderRadius: BorderRadius.circular(smallRadius),
      ),
      child: InkWell(
        onTap: () => customPopup(context, Builder(builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.values
                .map((e) => Column(
                      children: [
                        InkWell(
                          onTap: () {
                            widget.onChanged(e);
                            Navigator.pop(context);
                          },
                          child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: Center(child: Txt(e, bold: true))),
                        ),
                        divider()
                      ],
                    ))
                .toList(),
          );
        }), maxWidth: false),
        child: Row(
          children: [
            Txt(
                widget.selectedValue.isNotEmpty
                    ? widget.selectedValue
                    : widget.hint,
                color: widget.selectedValue.isNotEmpty
                    ? null
                    : context.invertedColor.withOpacity(.4)),
            const Spacer(),
            Icon(Icons.arrow_drop_down_rounded,
                color: context.iconColor, size: 25)
          ],
        ),
      ),
    );
  }
}
