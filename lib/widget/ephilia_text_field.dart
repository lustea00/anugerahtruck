import 'package:flutter/material.dart';
class EphiliaTextField extends StatelessWidget {
  final String label;
  final String value;
  final TextEditingController controler;
  final IconData icon;
  final bool enabled;
  final bool multiline;
  final String event;
  final bool obscure;

  const EphiliaTextField({Key key, this.label, this.value, this.controler, this.icon, this.enabled, this.multiline, this.event, this.obscure}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int _line = multiline == true ? 3 : 1;
    var _color = enabled == false ? Color.fromRGBO(220, 220, 220, 1) : Color.fromRGBO(214, 228, 255, 0.5);
    var _value = value == null ? "" : value;
    var _obscure = obscure == null ? false : obscure;
    TextEditingController _controller = controler == null ? new TextEditingController() : controler;
     _controller.text = _value;

    return (new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.black87, fontSize: 15, fontFamily: "Ubuntu"),
        ),
        SizedBox(height: 5),
        TextFormField(
          // initialValue: _value,
          controller: _controller,
          obscureText: _obscure,
          enabled: enabled,
          maxLines: _line,
          style: TextStyle(fontSize: 20, color: Color.fromRGBO(50, 50, 50, 1), fontFamily: "Ubuntu"),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(10),
            border: OutlineInputBorder(borderSide: const BorderSide(color: Colors.blue, width: 10),),
            labelStyle: TextStyle(fontSize: 20, color: Colors.black),
            suffixStyle: TextStyle(fontSize: 30),
            filled: true,
            fillColor: _color,
            disabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.blue, width: 1),),
            enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.blue, width: 1),),
          ),
          validator: (value) {
            if (value.isEmpty) {
              return 'Data tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    ));
  }
}
