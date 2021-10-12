import 'dart:js' as js;
import 'dart:html' as dom;
import 'dart:math';
import 'dart:ui' as ui;
import 'package:codemirror/codemirror.dart';
import 'package:flutter/scheduler.dart';
import 'package:resizable_widget/resizable_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

String sourceCode = """
#direction: down
#arrowSize: 1

[<flow> Catalog]->[<page> Category Overview]
[<page> Catalog]-> Fashion [<page> Product Overview]
[<page> Category Overview]-> [<page> Product Overview]
[<page> Product Overview]-> T-Shirt [<choice> Do you want to buy?]
[<choice> Do you want to buy?]-> Yes[<page> Order product]
[<choice> Do you want to buy?]-> No[<page> Goodbye]
[<page> Order product]-> [<flow> Order Process]
[<page> Goodbye]-> [<page> Any other questions?]
[<page> Any other questions?]-> No [<end> End]
""";

String helpDoc = """

Dialogflow CX Prototyper Tool
Created by Lee Boonstra, DevRel 2021

Classifier types:

[<flow> name]
[<page> name]
[<choice> name]
[<input> name]
---
[<label> name]
[<hidden> name]
[<start> name]
[<end> name]
[<usecase> name]
[<database> name]
[<reference> name]
[<note> name]

Association types:

-    association
->   association
<->  association
-->  dependency
<--> dependency
--   note
-/-  hidden
_>   weightless edge
__   weightless dashed edge

Styling settings:

#arrowSize: 1
#bendSize: 0.3
#direction: down | right
#gutter: 5
#edgeMargin: 0
#gravity: 1
#edges: hard | rounded
#background: transparent
#fill: #eee8d5; #fdf6e3
#fillArrows: false
#font: Calibri
#fontSize: 12
#leading: 1.25
#lineWidth: 3
#padding: 8
#spacing: 40
#stroke: #33322E
#zoom: 1
""";

void main() => runApp(DFPrototyper());

class DFPrototyper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MultiSplitViewExample(),
    );
  }
}

class MultiSplitViewExample extends StatefulWidget {
  @override
  _MultiSplitViewExampleState createState() => _MultiSplitViewExampleState();
}

class _MultiSplitViewExampleState extends State<MultiSplitViewExample> {
  String createdViewId = 'canvas_element';
  String createdViewIdEditor = 'editor_element';

  @override
  void initState() {
    super.initState();

    Map options = {
      'mode': 'uml',
      'theme': 'material-darker',
      'lineNumbers': 'true',
      'autoCloseTags': 'true',
    };

    CodeMirror editor;

    ui.platformViewRegistry.registerViewFactory(
        createdViewId,
        (int viewId) => dom.CanvasElement()
          ..style.border = 'none'
          ..style.margin = '10px'
          ..style.width = '100%'
          ..style.height = '100%');

    ui.platformViewRegistry.registerViewFactory(createdViewIdEditor,
        (int viewId) => dom.TextAreaElement()..id = 'textContainer');

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      js.context.callMethod('nomn', [sourceCode]);
    });

    SchedulerBinding.instance?.addPostFrameCallback((_) {
      editor = CodeMirror.fromTextArea(
          dom.querySelector('#textContainer') as dom.TextAreaElement?,
          options: options);

      editor.getDoc()?.setValue(sourceCode);
      editor.focus();
      editor.onChange.listen((e) {
        var edits = editor.getDoc()?.getValue();
        if (edits != null) {
          sourceCode = edits;
          js.context.callMethod('nomn', [sourceCode]);
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget buttons = Container(
        child: Row(children: [
          Text('Tools:'),
          SizedBox(width: 16),
          ElevatedButton(child: Text('Save'), onPressed: _onSaveButtonClick),
          /*
          SizedBox(width: 16),
          ElevatedButton(
              child: Text('Zoom In'), onPressed: _onZoomInButtonClick),
          SizedBox(width: 8),
          ElevatedButton(
              child: Text('Zoom Out'), onPressed: _onZoomOutButtonClick),
          SizedBox(width: 8),
          ElevatedButton(
              child: Text('Pan Left'), onPressed: _onPanLeftButtonClick),
          SizedBox(width: 8),
          ElevatedButton(
              child: Text('Pan Right'), onPressed: _onPanRightButtonClick),
          SizedBox(width: 8),
          ElevatedButton(child: Text('Pan Up'), onPressed: _onPanUpButtonClick),
          SizedBox(width: 8),
          ElevatedButton(
              child: Text('Pan Down'), onPressed: _onPanDownButtonClick),
          */
        ], crossAxisAlignment: CrossAxisAlignment.center),
        color: Colors.white,
        padding: EdgeInsets.all(8));

    ResizableWidget multiSplitView = ResizableWidget(
        isDisabledSmartHide: false, // optional
        separatorColor: Colors.grey, // optional
        separatorSize: 8, // optional
        percentages: [
          0.8,
          0.2,
        ], // optional
        children: [
          SingleChildScrollView(
              child: Center(
            child: HtmlElementView(viewType: createdViewId),
          )),
          SingleChildScrollView(
            padding: const EdgeInsets.all(15.0),
            child: SelectableText.rich(TextSpan(text: helpDoc)),
          ),
        ]);

    return Scaffold(
        appBar: AppBar(title: Text('Dialogflow CX Prototyper')),
        body: Column(children: [
          buttons,
          Flexible(
              flex: 2,
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Expanded(
                  flex: 2,
                  child: HtmlElementView(viewType: createdViewIdEditor),
                ),
                Expanded(
                  flex: 2,
                  child: multiSplitView,
                ),
              ]))
        ])
        // body: horizontal,
        );
  }

  _onSaveButtonClick() {
    js.context.callMethod('saveImg');
  }

  _onZoomInButtonClick() {
    js.context.callMethod('zoomIn', [sourceCode]);
  }

  _onZoomOutButtonClick() {
    js.context.callMethod('zoomOut', [sourceCode]);
  }

  _onPanLeftButtonClick() {
    js.context.callMethod('panLeft', [sourceCode]);
  }

  _onPanRightButtonClick() {
    js.context.callMethod('panRight', [sourceCode]);
  }

  _onPanUpButtonClick() {
    js.context.callMethod('panUp', [sourceCode]);
  }

  _onPanDownButtonClick() {
    js.context.callMethod('panDown');
  }
}
