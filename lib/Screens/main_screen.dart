import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_map_live_track/widgets/textfield.dart';
import 'package:google_map_live_track/provider/provider.dart';
import 'package:provider/provider.dart';

import 'map_screen.dart';

class Mainscreen extends StatelessWidget {
  const Mainscreen({super.key});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Consumer<LocationProvider>(builder: (context, getdata, child) {
      getdata.setUserId();
      return Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'Track Location',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: getdata.userId != null
                            ? Container(
                                height: size.height * 0.06,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.white,
                                  boxShadow: const [
                                    BoxShadow(
                                        color:
                                            Color.fromARGB(255, 184, 183, 183),
                                        blurRadius: 17,
                                        offset: Offset(4, 8))
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    const Expanded(
                                        flex: 1,
                                        child: Icon(
                                          Icons.person,
                                          color: Colors.blue,
                                        )),
                                    Expanded(
                                      flex: 5,
                                      child: Text(
                                        getdata.userId ?? '',
                                        style: const TextStyle(
                                            color: Colors.blue,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : CustomTextField(
                                controller: getdata.userIdController,
                                hintText: ' USER ID',
                                icon: Icons.person,
                                keyboardType: TextInputType.name,
                              ),
                      ),
                      const SizedBox(
                        width: 2,
                      ),
                      getdata.userId == null
                          ? CircleAvatar(
                              child: IconButton(
                                  onPressed: () {
                                    getdata.setLocation();
                                  },
                                  icon: const Icon(Icons.done)),
                            )
                          : SizedBox(
                              height: size.height * 0.05,
                              child: TextButton.icon(
                                onPressed: () {
                                  getdata.resetUserId();
                                },
                                label: const Text(
                                  'Reset User Id !',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                                icon: const Icon(
                                  Icons.arrow_circle_right_sharp,
                                  color: Colors.black,
                                ),
                              )),
                    ],
                  ),
                  const SizedBox(
                    height: 9,
                  ),
                  getdata.userId == null
                      ? const SizedBox()
                      : Row(
                          children: [
                            SizedBox(
                              width: size.width * 0.46,
                              child: ElevatedButton(
                                  onPressed: () => getdata.enableLiveLocation(),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green),
                                  child: const Text(
                                    'Enable Location',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  )),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            SizedBox(
                              width: size.width * 0.46,
                              child: ElevatedButton(
                                  onPressed: () =>
                                      getdata.disableLiveLocation(),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  child: const Text(
                                    'Disable Location',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  )),
                            ),
                          ],
                        ),
                  const SizedBox(
                    height: 10,
                  )
                ],
              ),
              Container(
                height: size.height * 0.68,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.all(8),
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('locations')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.white,
                            color: Colors.black,
                          ),
                        );
                      } else {
                        return ListView.separated(
                          itemCount: snapshot.data!.docs.length,
                          separatorBuilder: (context, index) => const SizedBox(
                            height: 10,
                          ),
                          itemBuilder: (context, index) {
                            var user = snapshot.data!.docs[index];
                            getdata.setTargetLocation(
                                user['latitude'], user['longitude']);
                            print(user);
                            return Row(
                              children: [
                                Expanded(
                                  child: Container(
                                      height: size.height * 0.08,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        color: Colors.white,
                                        boxShadow: const [
                                          BoxShadow(
                                              color: Color.fromARGB(
                                                  255, 192, 190, 190),
                                              blurRadius: 10,
                                              offset: Offset(4, 8))
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(15),
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.location_on,
                                            color: Colors.red,
                                            size: 22,
                                          ),
                                          const SizedBox(
                                            width: 7,
                                          ),
                                          Text(
                                            user['name'] ?? '',
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w300),
                                          ),
                                        ],
                                      )),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (context) => MapScreen(
                                                latitude: user['latitude'],
                                                longitude: user['longitude'],
                                              ))),
                                  child: const CircleAvatar(
                                    backgroundColor:
                                        Color.fromARGB(255, 216, 213, 213),
                                    radius: 26,
                                    child: Center(
                                      child: Icon(
                                        Icons.directions,
                                        color: Colors.black,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    }),
              ),
            ],
          ),
        ),
      );
    });
  }
}
