import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NFCReader(),
    );
  }
}

class NFCReader extends StatefulWidget {
  @override
  _NFCReaderState createState() => _NFCReaderState();
}

class _NFCReaderState extends State<NFCReader> {
  late IO.Socket socket;
  String tagData = "";

  @override
  void initState() {
    super.initState();

    // Conectar al servidor Python
    socket = IO.io('http://raspberrypi.local:12345', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    // Manejar conexión establecida
    socket.onConnect((_) {
      print('Conectado al servidor NFC');
    });

    // Manejar datos recibidos del servidor
    socket.on('tag_data', (data) {
      setState(() {
        tagData = data;
      });
      print('Datos del tag NFC recibidos: $data');
    });

    // Manejar errores de conexión
    socket.onError((error) {
      print('Error de conexión: $error');
    });

    // Inicializar la conexión
    socket.connect();
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }

  void readNFC() {
    // Enviar solicitud para leer NFC al servidor
    socket.emit('read_nfc', []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lector NFC'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Datos del Tag NFC:'),
            Text(
              tagData,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: readNFC,
              child: Text('Leer NFC'),
            ),
          ],
        ),
      ),
    );
  }
}

