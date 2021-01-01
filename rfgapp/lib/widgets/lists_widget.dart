import 'package:flutter/material.dart';
import 'package:rfgapp/screens/manager/orders/new_order.dart';

class ListWidget extends StatefulWidget {
  final bool isPic;
  final int index;
  final String name;
  final double price;
  final double total;
  final double qty;
  final String info;
  final String department;
  final String imageurl;
  final Map<dynamic, dynamic> map;
  ListWidget(
      {@required this.isPic,
      @required this.index,
      @required this.name,
      @required this.price,
      @required this.qty,
      @required this.total,
      @required this.imageurl,
      @required this.map,
      @required this.department,
      @required this.info});

  @override
  _ListWidgetState createState() => _ListWidgetState();
}

class _ListWidgetState extends State<ListWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return AddNewOrder(
              customerName: widget.name,
              department: widget.department,
              info: widget.info,
              map: widget.map,
            );
          },
        ));
      },
      child: Container(
          width: double.infinity,
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                  width: 50,
                  height: 25,
                  //  margin: EdgeInsets.symmetric(vertical:25,horizontal: 25),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueGrey, width: 1),
                      borderRadius: BorderRadius.circular(3)),
                  child: Center(
                    child: Padding(
                        padding: EdgeInsets.all(4),
                        child:
                            Text(widget.index.toString(), style: textStyle())),
                  )),
              ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  child: widget.imageurl == null
                      ? Image.asset(
                          'assets/image/app-icon2.jpg',
                          width: 100,
                          height: 90,
                          fit: BoxFit.fill,
                        )
                      : Image.network(
                          widget.imageurl,
                          fit: BoxFit.cover,
                          width: 100,
                          height: 90,
                        )),
              Container(
                width: 100,
                child: Text(
                  widget.name,
                  style: textStyle(),
                ),
              ),
              VerticalDivider(
                indent: 25,
                endIndent: 25,
                thickness: 1,
                color: Colors.grey,
              ),
              if (widget.isPic == false)
                Text(widget.qty.toString(), style: textStyle()),
              if (widget.isPic == false)
                VerticalDivider(
                  indent: 25,
                  endIndent: 25,
                  thickness: 1,
                  color: Colors.grey,
                ),
              if (widget.isPic == false)
                Text(widget.price.toString(), style: textStyle()),
              if (widget.isPic == false)
                VerticalDivider(
                  indent: 25,
                  endIndent: 25,
                  thickness: 1,
                  color: Colors.grey,
                ),
              Text(widget.total.toString(), style: textStyle()),
            ],
          )),
    );
  }

  TextStyle textStyle() {
    return TextStyle(fontSize: 16, color: Colors.blue);
  }
}
