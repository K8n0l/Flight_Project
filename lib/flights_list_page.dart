import 'package:flutter/material.dart';
import 'flights_database_helper.dart';
import 'secure_storage_helper.dart';

class FlightsListPage extends StatefulWidget {
  @override
  _FlightsListPageState createState() => _FlightsListPageState();
}

class _FlightsListPageState extends State<FlightsListPage> {
  final FlightsDatabaseHelper dbHelper = FlightsDatabaseHelper();
  final SecureStorageHelper secureStorageHelper = SecureStorageHelper();
  List<Map<String, dynamic>> flights = [];
  TextEditingController departureCityController = TextEditingController();
  TextEditingController destinationCityController = TextEditingController();
  TextEditingController departureTimeController = TextEditingController();
  TextEditingController arrivalTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchFlights();
  }

  void _fetchFlights() async {
    List<Map<String, dynamic>> fetchedFlights = await dbHelper.getAllFlights();
    setState(() {
      flights = fetchedFlights;
    });
  }

  void _addFlight() async {
    if (departureCityController.text.isNotEmpty && destinationCityController.text.isNotEmpty && departureTimeController.text.isNotEmpty && arrivalTimeController.text.isNotEmpty) {
      Map<String, dynamic> newFlight = {
        'departureCity': departureCityController.text,
        'destinationCity': destinationCityController.text,
        'departureTime': departureTimeController.text,
        'arrivalTime': arrivalTimeController.text,
      };
      await dbHelper.saveFlight(newFlight);
      _fetchFlights();
      departureCityController.clear();
      destinationCityController.clear();
      departureTimeController.clear();
      arrivalTimeController.clear();
    }
  }

  void _updateFlight(Map<String, dynamic> flight) async {
    await dbHelper.updateFlight(flight);
    _fetchFlights();
  }

  void _deleteFlight(int id) async {
    await dbHelper.deleteFlight(id);
    _fetchFlights();
  }

  void _showFlightDetails(Map<String, dynamic> flight) {
    departureCityController.text = flight['departureCity'];
    destinationCityController.text = flight['destinationCity'];
    departureTimeController.text = flight['departureTime'];
    arrivalTimeController.text = flight['arrivalTime'];
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Flight Details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: departureCityController,
                  decoration: InputDecoration(labelText: 'Departure City'),
                ),
                TextField(
                  controller: destinationCityController,
                  decoration: InputDecoration(labelText: 'Destination City'),
                ),
                TextField(
                  controller: departureTimeController,
                  decoration: InputDecoration(labelText: 'Departure Time'),
                ),
                TextField(
                  controller: arrivalTimeController,
                  decoration: InputDecoration(labelText: 'Arrival Time'),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text('Update'),
                onPressed: () {
                  Map<String, dynamic> updatedFlight = {
                    'id': flight['id'],
                    'departureCity': departureCityController.text,
                    'destinationCity': destinationCityController.text,
                    'departureTime': departureTimeController.text,
                    'arrivalTime': arrivalTimeController.text,
                  };
                  _updateFlight(updatedFlight);
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text('Delete'),
                onPressed: () {
                  _deleteFlight(flight['id']);
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Flights List',
          style: TextStyle(
            color: Colors.white, // Change text color to white
          ),
        ),
        backgroundColor: Colors.black, // Change AppBar color to black
        iconTheme: IconThemeData(
          color: Colors.white, // Change back button color to white
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info, color: Colors.white), // Change icon color to white
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Instructions'),
                    content: Text('Use the button below to add new flights. Select a flight to view, update, or delete.'),
                    actions: [
                      TextButton(
                        child: Text('OK'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/background1.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _addFlightDialog,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Add Flight',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: flights.length,
                    itemBuilder: (context, index) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          title: Text(
                            '${flights[index]['departureCity']} to ${flights[index]['destinationCity']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Departure: ${flights[index]['departureTime']} - Arrival: ${flights[index]['arrivalTime']}',
                          ),
                          leading: CircleAvatar(
                            backgroundImage: AssetImage('images/flight.jpeg'), // Your image asset
                            radius: 30,
                          ),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () => _showFlightDetails(flights[index]),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addFlightDialog() {
    departureCityController.clear();
    destinationCityController.clear();
    departureTimeController.clear();
    arrivalTimeController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Flight'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: departureCityController,
                decoration: InputDecoration(labelText: 'Departure City'),
              ),
              TextField(
                controller: destinationCityController,
                decoration: InputDecoration(labelText: 'Destination City'),
              ),
              TextField(
                controller: departureTimeController,
                decoration: InputDecoration(labelText: 'Departure Time'),
              ),
              TextField(
                controller: arrivalTimeController,
                decoration: InputDecoration(labelText: 'Arrival Time'),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Add'),
              onPressed: () {
                _addFlight();
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
