import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';


class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [
    //Band(id: '1', name: 'Offspring', votes: 5 ),
    //Band(id: '2', name: 'Queen', votes: 1 ),
    //Band(id: '3', name: 'Triana', votes: 2 ),
    //Band(id: '4', name: 'Fito & Fitipaldis', votes: 5 ),
  ];

  @override
  void initState() {
    
    final socketService = Provider.of<SocketService>(context, listen: false ); 

    socketService.socket.on('active-bands', (payload) {
      
      bands = (payload as List).map( (band) => Band.fromMap(band) )
      .toList();

      setState(() {});

    });
    super.initState();
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false); 
    socketService.socket.off('acyive-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context); 

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('BandNames', style: TextStyle( color: Colors.black87, ),),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: const EdgeInsets.only( right: 10 ),
            child: ( socketService.serverStatus == ServerStatus.Online )
              ? Icon( Icons.check_circle, color: Colors.blue[300] )
              : Icon( Icons.offline_bolt, color: Colors.red, ),
          )
        ],
      ),
      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: ( context, i ) => _bandTile( bands[i]),
        
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 1,
        onPressed: addNewBand
        ),
   );
  }

  Widget _bandTile( Band band ) {

    final socketService = Provider.of<SocketService>(context, listen: false);
    
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: ( direction ) {
        print('direction: $direction');
        //TODO: llamar el borrado en el servidor
      },
      background: Container(
        padding: EdgeInsets.only( left: 8.0 ),
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerLeft,
          //child: Text('Delete Band', style: TextStyle( color: Colors.white ) ),
          child: Icon( Icons.delete, color: Colors.white,),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Text( band.name.substring(0,2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text( band.name ),
        trailing: Text('${ band.votes }', style: TextStyle( fontSize: 20 ),),
        onTap: () {
          socketService.socket.emit('vote-band', { 'id': band.id } );
        },
      ),
    );
  }

  addNewBand() {

    final textController = new TextEditingController();

    if ( Platform.isAndroid ) {
      // Android
      return showDialog(
          context: context, 
          builder: ( context ) {
            return AlertDialog(
              title: Text('New Band name:'),
              content: TextField(
                controller: textController,
              ),
              actions: [
                MaterialButton(
                  child: Text('Add'),
                  elevation: 5,
                  textColor: Colors.blue,
                  onPressed: () => addBandToList( textController.text )
                )
              ],
            );
          }
        );
    }

    showCupertinoDialog(
      context: context, 
      builder: (_) {
        return CupertinoAlertDialog(
          title: Text('New band name:'),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Add'),
              onPressed: () => addBandToList(textController.text),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text('Dismiss'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      }
    );
  }

  void addBandToList( String name ) {

    if ( name.length > 1 ) {
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.emit('add-band', { name: name } );
      }

    Navigator.pop(context);
  }
}