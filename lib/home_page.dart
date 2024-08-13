import 'package:intl/intl.dart'; // Para formatação de data
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para FilteringTextInputFormatter
import 'package:contacts_app/contact.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController cpfController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();

  final List<Contact> contacts = <Contact>[];

  int selectedIndex = -1;
  DateTime? selectedDate;

  final RegExp _phoneRegex = RegExp(r'^\d{10}$');
  final RegExp _cpfRegex = RegExp(r'^\d{3}\.\d{3}\.\d{3}-\d{2}$');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Contacts List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildTextField(nameController, 'Nome', false),
            const SizedBox(height: 10),
            _buildTextField(contactController, 'Telefone', true),
            const SizedBox(height: 10),
            _buildTextField(cpfController, 'CPF', false),
            const SizedBox(height: 10),
            _buildTextField(addressController, 'Endereço', false),
            const SizedBox(height: 10),
            TextField(
              controller: birthDateController,
              readOnly: true,
              decoration: const InputDecoration(
                hintText: 'Data de nascimento',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() {
                    selectedDate = pickedDate;
                    birthDateController.text =
                        DateFormat('yyyy-MM-dd').format(selectedDate!);
                  });
                }
              },
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _saveContact,
                  child: const Text('Save'),
                ),
                ElevatedButton(
                  onPressed: _updateContact,
                  child: const Text('Update'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            contacts.isEmpty
                ? const Text(
                    'No Contact yet..',
                    style: TextStyle(fontSize: 22),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: contacts.length,
                      itemBuilder: (context, index) => getRow(index),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hintText, bool isPhone) {
    return TextField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
      ),
      inputFormatters: isPhone ? [FilteringTextInputFormatter.digitsOnly] : [],
    );
  }

  void _saveContact() {
    String name = nameController.text.trim();
    String contact = contactController.text.trim();
    String cpf = cpfController.text.trim();
    String address = addressController.text.trim();
    if (name.isNotEmpty &&
        contact.isNotEmpty &&
        cpf.isNotEmpty &&
        address.isNotEmpty &&
        selectedDate != null) {
      if (_phoneRegex.hasMatch(contact) && _cpfRegex.hasMatch(cpf)) {
        setState(() {
          nameController.clear();
          contactController.clear();
          cpfController.clear();
          addressController.clear();
          birthDateController.clear();
          contacts.add(Contact(
            name: name,
            contact: contact,
            cpf: cpf,
            address: address,
            birthDate: selectedDate!,
          ));
        });
      } else {
        _showErrorDialog('Telefone ou CPF inválido.');
      }
    } else {
      _showErrorDialog('Todos os campos devem ser preenchidos.');
    }
  }

  void _updateContact() {
    if (selectedIndex != -1) {
      String name = nameController.text.trim();
      String contact = contactController.text.trim();
      String cpf = cpfController.text.trim();
      String address = addressController.text.trim();
      if (name.isNotEmpty &&
          contact.isNotEmpty &&
          cpf.isNotEmpty &&
          address.isNotEmpty &&
          selectedDate != null) {
        if (_phoneRegex.hasMatch(contact) && _cpfRegex.hasMatch(cpf)) {
          setState(() {
            nameController.clear();
            contactController.clear();
            cpfController.clear();
            addressController.clear();
            birthDateController.clear();
            contacts[selectedIndex] = Contact(
              name: name,
              contact: contact,
              cpf: cpf,
              address: address,
              birthDate: selectedDate!,
            );
            selectedIndex = -1;
          });
        } else {
          _showErrorDialog('Telefone ou CPF inválido.');
        }
      } else {
        _showErrorDialog('Todos os campos devem ser preenchidos.');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget getRow(int index) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              index % 2 == 0 ? Colors.deepPurpleAccent : Colors.purple,
          foregroundColor: Colors.white,
          child: Text(
            contacts[index].name[0],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contacts[index].name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(contacts[index].contact),
            Text('CPF: ${contacts[index].cpf}'),
            Text('Address: ${contacts[index].address}'),
            Text(
                'Birth Date: ${DateFormat('yyyy-MM-dd').format(contacts[index].birthDate)}'),
          ],
        ),
        trailing: SizedBox(
          width: 90,
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  nameController.text = contacts[index].name;
                  contactController.text = contacts[index].contact;
                  cpfController.text = contacts[index].cpf;
                  addressController.text = contacts[index].address;
                  selectedDate = contacts[index].birthDate;
                  birthDateController.text =
                      DateFormat('yyyy-MM-dd').format(selectedDate!);
                  setState(() {
                    selectedIndex = index;
                  });
                },
                child: const Icon(Icons.edit),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    contacts.removeAt(index);
                  });
                },
                child: const Icon(Icons.delete),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
