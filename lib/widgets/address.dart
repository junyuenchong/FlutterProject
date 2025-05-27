import 'package:ecommerce/controller/userpurchase_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddressManagement extends StatelessWidget {
  final TextEditingController _addressController = TextEditingController();

  AddressManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserPurchaseController>(builder: (ctrl) {
      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Display addresses
                  Obx(() => Column(
                        children: ctrl.addresses.map((address) {
                          bool isDefault = ctrl.defaultAddress == address;
                          return ListTile(
                            title: Text(address),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isDefault)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editAddress(ctrl, address),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    ctrl.deleteAddress(address);
                                  },
                                ),
                              ],
                            ),
                            onTap: () {
                              ctrl.setDefaultAddress(address);
                            },
                          );
                        }).toList(),
                      )),
                  // Add new address field
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: TextField(
                      controller: _addressController,
                      decoration: const InputDecoration(hintText: 'Add New Address'),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          String newAddress = _addressController.text;
                          if (newAddress.isNotEmpty) {
                            ctrl.addAddress(newAddress);
                            _addressController.clear();
                          }
                        },
                        child: const Text('Add Address'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          _addressController.clear();
                        },
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  // Edit an existing address
  void _editAddress(UserPurchaseController ctrl, String oldAddress) {
    TextEditingController controller = TextEditingController(text: oldAddress);
    Get.defaultDialog(
      title: 'Edit Address',
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: 'New Address'),
      ),
      confirm: ElevatedButton(
        onPressed: () {
          String updatedAddress = controller.text;
          if (updatedAddress.isNotEmpty) {
            ctrl.updateAddress(oldAddress, updatedAddress);
            Get.back();
          }
        },
        child: const Text('Update'),
      ),
      cancel: ElevatedButton(
        onPressed: () => Get.back(),
        child: const Text('Cancel'),
      ),
    );
  }
}
