import 'dart:html' as html;

removeElementIfExist(String id) {
  final ele = html.querySelector('#$id');
  if (html.querySelector('#$id') != null) {
    ele!.remove();
  }
}

addElement(html.Element element) {
  html.querySelector('body')!.children.add(element);
}

replaceScriptElement(String id, String code) {
  removeElementIfExist(id);
  addElement(
    html.ScriptElement()
      ..id = id
      ..innerHtml = code,
  );
}
