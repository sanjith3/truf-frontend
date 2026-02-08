import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:turfzone/booking/booking_screen.dart';
import 'package:turfzone/models/turf.dart';
import 'package:turfzone/features/profile/profile_screen.dart';
import 'package:turfzone/features/Admindashboard/admin_screen.dart';
import '../../turffdetail/turfdetails_screen.dart';
import '../../services/turf_data_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turfzone/features/tournament/tournament_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Turf> _filteredTurfs = [];
  final TurfDataService _turfService = TurfDataService();
  String _selectedLocation = "Coimbatore";
  String _selectedState = "Tamil Nadu";
  bool _isLocationLoading = false;
  String _userName = "";
  bool _isPartner = false;

  // Offer filter
  bool _offerFilter = false;

  // All Indian states and their districts (Sorted Alphabetically)
  final Map<String, List<String>> _indianStates = {
    'Andaman and Nicobar Islands': ['Nicobar', 'North and Middle Andaman', 'South Andaman'],
    'Andhra Pradesh': [
      'Anantapur', 'Chittoor', 'East Godavari', 'Guntur', 'Kadapa', 'Krishna',
      'Kurnool', 'Nellore', 'Prakasam', 'Srikakulam', 'Visakhapatnam', 'Vizianagaram', 'West Godavari'
    ],
    'Arunachal Pradesh': [
      'Anjaw', 'Changlang', 'Dibang Valley', 'East Kameng', 'East Siang', 'Kamle',
      'Kra Daadi', 'Kurung Kumey', 'Lepa Rada', 'Lohit', 'Longding', 'Lower Dibang Valley',
      'Lower Siang', 'Lower Subansiri', 'Namsai', 'Pakke Kessang', 'Papum Pare', 'Shi Yomi',
      'Siang', 'Tawang', 'Tirap', 'Upper Siang', 'Upper Subansiri', 'West Kameng', 'West Siang'
    ],
    'Assam': [
      'Baksa', 'Barpeta', 'Biswanath', 'Bongaigaon', 'Cachar', 'Charaideo', 'Chirang',
      'Darrang', 'Dhemaji', 'Dhubri', 'Dibrugarh', 'Dima Hasao', 'Goalpara', 'Golaghat',
      'Hailakandi', 'Hojai', 'Jorhat', 'Kamrup', 'Kamrup Metropolitan', 'Karbi Anglong',
      'Karimganj', 'Kokrajhar', 'Lakhimpur', 'Majuli', 'Morigaon', 'Nagaon', 'Nalbari',
      'Sivasagar', 'Sonitpur', 'South Salmara-Mankachar', 'Tinsukia', 'Udalguri', 'West Karbi Anglong'
    ],
    'Bihar': [
      'Araria', 'Arwal', 'Aurangabad', 'Banka', 'Begusarai', 'Bhagalpur', 'Bhojpur',
      'Buxar', 'Darbhanga', 'East Champaran', 'Gaya', 'Gopalganj', 'Jamui', 'Jehanabad',
      'Kaimur', 'Katihar', 'Khagaria', 'Kishanganj', 'Lakhisarai', 'Madhepura', 'Madhubani',
      'Munger', 'Muzaffarpur', 'Nalanda', 'Nawada', 'Patna', 'Purnia', 'Rohtas', 'Saharsa',
      'Samastipur', 'Saran', 'Sheikhpura', 'Sheohar', 'Sitamarhi', 'Siwan', 'Supaul', 'Vaishali', 'West Champaran'
    ],
    'Chandigarh': ['Chandigarh'],
    'Chhattisgarh': [
      'Balod', 'Baloda Bazar', 'Balrampur', 'Bastar', 'Bemetara', 'Bijapur', 'Bilaspur',
      'Dantewada', 'Dhamtari', 'Durg', 'Gariaband', 'Gaurela-Pendra-Marwahi', 'Janjgir-Champa',
      'Jashpur', 'Kabirdham', 'Kanker', 'Kondagaon', 'Korba', 'Koriya', 'Mahasamund', 'Mungeli',
      'Narayanpur', 'Raigarh', 'Raipur', 'Rajnandgaon', 'Sukma', 'Surajpur', 'Surguja'
    ],
    'Dadra and Nagar Haveli and Daman and Diu': ['Dadra and Nagar Haveli', 'Daman', 'Diu'],
    'Delhi': ['Central Delhi', 'East Delhi', 'New Delhi', 'North Delhi', 'North East Delhi', 'North West Delhi', 'Shahdara', 'South Delhi', 'South East Delhi', 'South West Delhi', 'West Delhi'],
    'Goa': ['North Goa', 'South Goa'],
    'Gujarat': [
      'Ahmedabad', 'Amreli', 'Anand', 'Aravalli', 'Banaskantha', 'Bharuch', 'Bhavnagar',
      'Botad', 'Chhota Udepur', 'Dahod', 'Dang', 'Devbhoomi Dwarka', 'Gandhinagar', 'Gir Somnath',
      'Jamnagar', 'Junagadh', 'Kheda', 'Kutch', 'Mahisagar', 'Mehsana', 'Morbi', 'Narmada',
      'Navsari', 'Panchmahal', 'Patan', 'Porbandar', 'Rajkot', 'Sabarkantha', 'Surat',
      'Surendranagar', 'Tapi', 'Vadodara', 'Valsad'
    ],
    'Haryana': [
      'Ambala', 'Bhiwani', 'Charkhi Dadri', 'Faridabad', 'Fatehabad', 'Gurugram', 'Hisar',
      'Jhajjar', 'Jind', 'Kaithal', 'Karnal', 'Kurukshetra', 'Mahendragarh', 'Nuh', 'Palwal',
      'Panchkula', 'Panipat', 'Rewari', 'Rohtak', 'Sirsa', 'Sonipat', 'Yamunanagar'
    ],
    'Himachal Pradesh': [
      'Bilaspur', 'Chamba', 'Hamirpur', 'Kangra', 'Kinnaur', 'Kullu', 'Lahaul and Spiti',
      'Mandi', 'Shimla', 'Sirmaur', 'Solan', 'Una'
    ],
    'Jammu and Kashmir': [
      'Anantnag', 'Bandipora', 'Baramulla', 'Budgam', 'Doda', 'Ganderbal', 'Jammu',
      'Kathua', 'Kishtwar', 'Kulgam', 'Kupwara', 'Poonch', 'Pulwama', 'Rajouri', 'Ramban',
      'Reasi', 'Samba', 'Shopian', 'Srinagar', 'Udhampur'
    ],
    'Jharkhand': [
      'Bokaro', 'Chatra', 'Deoghar', 'Dhanbad', 'Dumka', 'East Singhbhum', 'Garhwa',
      'Giridih', 'Godda', 'Gumla', 'Hazaribagh', 'Jamtara', 'Khunti', 'Koderma', 'Latehar',
      'Lohardaga', 'Pakur', 'Palamu', 'Ramgarh', 'Ranchi', 'Sahibganj', 'Seraikela Kharsawan',
      'Simdega', 'West Singhbhum'
    ],
    'Karnataka': [
      'Bagalkot', 'Ballari', 'Belagavi', 'Bengaluru Rural', 'Bengaluru Urban', 'Bidar',
      'Chamarajanagar', 'Chikkaballapur', 'Chikkamagaluru', 'Chitradurga', 'Dakshina Kannada',
      'Davanagere', 'Dharwad', 'Gadag', 'Hassan', 'Haveri', 'Kalaburagi', 'Kodagu', 'Kolar',
      'Koppal', 'Mandya', 'Mysuru', 'Raichur', 'Ramanagara', 'Shivamogga', 'Tumakuru',
      'Udupi', 'Uttara Kannada', 'Vijayapura', 'Yadgir'
    ],
    'Kerala': [
      'Alappuzha', 'Ernakulam', 'Idukki', 'Kannur', 'Kasaragod', 'Kollam', 'Kottayam',
      'Kozhikode', 'Malappuram', 'Palakkad', 'Pathanamthitta', 'Thiruvananthapuram', 'Thrissur', 'Wayanad'
    ],
    'Ladakh': ['Kargil', 'Leh'],
    'Lakshadweep': ['Lakshadweep'],
    'Madhya Pradesh': [
      'Agar Malwa', 'Alirajpur', 'Anuppur', 'Ashoknagar', 'Balaghat', 'Barwani', 'Betul',
      'Bhind', 'Bhopal', 'Burhanpur', 'Chhatarpur', 'Chhindwara', 'Damoh', 'Datia', 'Dewas',
      'Dhar', 'Dindori', 'Guna', 'Gwalior', 'Harda', 'Hoshangabad', 'Indore', 'Jabalpur',
      'Jhabua', 'Katni', 'Khandwa', 'Khargone', 'Mandla', 'Mandsaur', 'Morena', 'Narsinghpur',
      'Neemuch', 'Niwari', 'Panna', 'Raisen', 'Rajgarh', 'Ratlam', 'Rewa', 'Sagar', 'Satna',
      'Sehore', 'Seoni', 'Shahdol', 'Shajapur', 'Sheopur', 'Shivpuri', 'Sidhi', 'Singrauli',
      'Tikamgarh', 'Ujjain', 'Umaria', 'Vidisha'
    ],
    'Maharashtra': [
      'Ahmednagar', 'Akola', 'Amravati', 'Aurangabad', 'Beed', 'Bhandara', 'Buldhana',
      'Chandrapur', 'Dhule', 'Gadchiroli', 'Gondia', 'Hingoli', 'Jalgaon', 'Jalna', 'Kolhapur',
      'Latur', 'Mumbai City', 'Mumbai Suburban', 'Nagpur', 'Nanded', 'Nandurbar', 'Nashik',
      'Osmanabad', 'Palghar', 'Parbhani', 'Pune', 'Raigad', 'Ratnagiri', 'Sangli', 'Satara',
      'Sindhudurg', 'Solapur', 'Thane', 'Wardha', 'Washim', 'Yavatmal'
    ],
    'Manipur': [
      'Bishnupur', 'Chandel', 'Churachandpur', 'Imphal East', 'Imphal West', 'Jiribam',
      'Kakching', 'Kamjong', 'Kangpokpi', 'Noney', 'Pherzawl', 'Senapati', 'Tamenglong',
      'Tengnoupal', 'Thoubal', 'Ukhrul'
    ],
    'Meghalaya': [
      'East Garo Hills', 'East Jaintia Hills', 'East Khasi Hills', 'North Garo Hills',
      'Ri Bhoi', 'South Garo Hills', 'South West Garo Hills', 'South West Khasi Hills',
      'West Garo Hills', 'West Jaintia Hills', 'West Khasi Hills'
    ],
    'Mizoram': [
      'Aizawl', 'Champhai', 'Hnahthial', 'Khawzawl', 'Kolasib', 'Lawngtlai', 'Lunglei',
      'Mamit', 'Saiha', 'Saitual', 'Serchhip'
    ],
    'Nagaland': [
      'Dimapur', 'Kiphire', 'Kohima', 'Longleng', 'Mokokchung', 'Mon', 'Noklak',
      'Peren', 'Phek', 'Tuensang', 'Wokha', 'Zunheboto'
    ],
    'Odisha': [
      'Angul', 'Balangir', 'Balasore', 'Bargarh', 'Bhadrak', 'Boudh', 'Cuttack',
      'Deogarh', 'Dhenkanal', 'Gajapati', 'Ganjam', 'Jagatsinghpur', 'Jajpur', 'Jharsuguda',
      'Kalahandi', 'Kandhamal', 'Kendrapara', 'Kendujhar', 'Khordha', 'Koraput', 'Malkangiri',
      'Mayurbhanj', 'Nabarangpur', 'Nayagarh', 'Nuapada', 'Puri', 'Rayagada', 'Sambalpur',
      'Subarnapur', 'Sundargarh'
    ],
    'Puducherry': ['Karaikal', 'Mahe', 'Puducherry', 'Yanam'],
    'Punjab': [
      'Amritsar', 'Barnala', 'Bathinda', 'Faridkot', 'Fatehgarh Sahib', 'Fazilka', 'Ferozepur',
      'Gurdaspur', 'Hoshiarpur', 'Jalandhar', 'Kapurthala', 'Ludhiana', 'Mansa', 'Moga',
      'Muktsar', 'Pathankot', 'Patiala', 'Rupnagar', 'Sahibzada Ajit Singh Nagar', 'Sangrur',
      'Shahid Bhagat Singh Nagar', 'Sri Muktsar Sahib', 'Tarn Taran'
    ],
    'Rajasthan': [
      'Ajmer', 'Alwar', 'Banswara', 'Baran', 'Barmer', 'Bharatpur', 'Bhilwara', 'Bikaner',
      'Bundi', 'Chittorgarh', 'Churu', 'Dausa', 'Dholpur', 'Dungarpur', 'Hanumangarh',
      'Jaipur', 'Jaisalmer', 'Jalore', 'Jhalawar', 'Jhunjhunu', 'Jodhpur', 'Karauli',
      'Kota', 'Nagaur', 'Pali', 'Pratapgarh', 'Rajsamand', 'Sawai Madhopur', 'Sikar',
      'Sirohi', 'Sri Ganganagar', 'Tonk', 'Udaipur'
    ],
    'Sikkim': ['East Sikkim', 'North Sikkim', 'South Sikkim', 'West Sikkim'],
    'Tamil Nadu': [
      'Ariyalur', 'Chengalpattu', 'Chennai', 'Coimbatore', 'Cuddalore', 'Dharmapuri',
      'Dindigul', 'Erode', 'Kallakurichi', 'Kancheepuram', 'Kanyakumari', 'Karur',
      'Krishnagiri', 'Madurai', 'Mayiladuthurai', 'Nagapattinam', 'Namakkal', 'Nilgiris',
      'Perambalur', 'Pudukkottai', 'Ramanathapuram', 'Ranipet', 'Salem', 'Sivaganga',
      'Tenkasi', 'Thanjavur', 'Theni', 'Thoothukudi', 'Tiruchirappalli', 'Tirunelveli',
      'Tirupathur', 'Tiruppur', 'Tiruvallur', 'Tiruvannamalai', 'Tiruvarur', 'Vellore',
      'Viluppuram', 'Virudhunagar'
    ],
    'Telangana': [
      'Adilabad', 'Bhadradri Kothagudem', 'Hyderabad', 'Jagtial', 'Jangaon', 'Jayashankar Bhupalpally',
      'Jogulamba Gadwal', 'Kamareddy', 'Karimnagar', 'Khammam', 'Kumuram Bheem Asifabad',
      'Mahabubabad', 'Mahabubnagar', 'Mancherial', 'Medak', 'Medchal Malkajgiri', 'Mulugu',
      'Nagarkurnool', 'Nalgonda', 'Narayanpet', 'Nirmal', 'Nizamabad', 'Peddapalli',
      'Rajanna Sircilla', 'Rangareddy', 'Sangareddy', 'Siddipet', 'Suryapet', 'Vikarabad',
      'Wanaparthy', 'Warangal Rural', 'Warangal Urban', 'Yadadri Bhuvanagiri'
    ],
    'Tripura': [
      'Dhalai', 'Gomati', 'Khowai', 'North Tripura', 'Sepahijala', 'South Tripura', 'Unakoti', 'West Tripura'
    ],
    'Uttar Pradesh': [
      'Agra', 'Aligarh', 'Allahabad', 'Ambedkar Nagar', 'Amethi', 'Amroha', 'Auraiya',
      'Azamgarh', 'Baghpat', 'Bahraich', 'Ballia', 'Balrampur', 'Banda', 'Barabanki',
      'Bareilly', 'Basti', 'Bhadohi', 'Bijnor', 'Budaun', 'Bulandshahr', 'Chandauli',
      'Chitrakoot', 'Deoria', 'Etah', 'Etawah', 'Faizabad', 'Farrukhabad', 'Fatehpur',
      'Firozabad', 'Gautam Buddh Nagar', 'Ghaziabad', 'Ghazipur', 'Gonda', 'Gorakhpur',
      'Hamirpur', 'Hapur', 'Hardoi', 'Hathras', 'Jalaun', 'Jaunpur', 'Jhansi', 'Kannauj',
      'Kanpur Dehat', 'Kanpur Nagar', 'Kasganj', 'Kaushambi', 'Kheri', 'Kushinagar',
      'Lakhimpur Kheri', 'Lalitpur', 'Lucknow', 'Maharajganj', 'Mahoba', 'Mainpuri',
      'Mathura', 'Mau', 'Meerut', 'Mirzapur', 'Moradabad', 'Muzaffarnagar', 'Pilibhit',
      'Pratapgarh', 'Rae Bareli', 'Rampur', 'Saharanpur', 'Sambhal', 'Sant Kabir Nagar',
      'Shahjahanpur', 'Shamli', 'Shravasti', 'Siddharthnagar', 'Sitapur', 'Sonbhadra',
      'Sultanpur', 'Unnao', 'Varanasi'
    ],
    'Uttarakhand': [
      'Almora', 'Bageshwar', 'Chamoli', 'Champawat', 'Dehradun', 'Haridwar', 'Nainital',
      'Pauri Garhwal', 'Pithoragarh', 'Rudraprayag', 'Tehri Garhwal', 'Udham Singh Nagar', 'Uttarkashi'
    ],
    'West Bengal': [
      'Alipurduar', 'Bankura', 'Birbhum', 'Cooch Behar', 'Dakshin Dinajpur', 'Darjeeling',
      'Hooghly', 'Howrah', 'Jalpaiguri', 'Jhargram', 'Kalimpong', 'Kolkata', 'Malda',
      'Murshidabad', 'Nadia', 'North 24 Parganas', 'Paschim Bardhaman', 'Paschim Medinipur',
      'Purba Bardhaman', 'Purba Medinipur', 'Purulia', 'South 24 Parganas', 'Uttar Dinajpur'
    ],
  };

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          _userName = prefs.getString('userName') ?? "";
          _isPartner = prefs.getBool('isPartner') ?? false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  // Get current location
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLocationLoading = true;
    });

    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are permanently denied.'),
          ),
        );
        return;
      }

      // Get position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // In a real app, you would reverse geocode to get city and state
      // For now, we'll simulate with a default
      if (mounted) {
        setState(() {
          _selectedState = "Tamil Nadu";
          _selectedLocation = "Coimbatore";
          _applyFilters();
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location set to $_selectedLocation, $_selectedState'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error getting location: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLocationLoading = false;
        });
      }
    }
  }

  void _showLocationPicker() {
    String? tempSelectedState = _selectedState;
    String? tempSelectedCity = _selectedLocation;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Select Location",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Current Location Button
                  Container(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLocationLoading
                          ? null
                          : () {
                              _getCurrentLocation();
                              Navigator.pop(context);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[50],
                        foregroundColor: Colors.green[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                      icon: _isLocationLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location, size: 20),
                      label: Text(
                        _isLocationLoading
                            ? 'Detecting Location...'
                            : 'Use Current Location',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // State and City Selection
                  Expanded(
                    child: Row(
                      children: [
                        // States List
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                  color: Colors.grey[300]!,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: ListView.builder(
                              itemCount: _indianStates.keys.length,
                              itemBuilder: (context, index) {
                                final state = _indianStates.keys.elementAt(
                                  index,
                                );
                                return ListTile(
                                  title: Text(
                                    state,
                                    style: TextStyle(
                                      fontWeight: tempSelectedState == state
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: tempSelectedState == state
                                          ? Colors.green[800]
                                          : Colors.black87,
                                    ),
                                  ),
                                  trailing: tempSelectedState == state
                                      ? Icon(
                                          Icons.check,
                                          color: Colors.green[800],
                                          size: 20,
                                        )
                                      : null,
                                  onTap: () {
                                    setState(() {
                                      tempSelectedState = state;
                                      tempSelectedCity =
                                          _indianStates[state]!.first;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ),

                        // Cities List
                        Expanded(
                          flex: 3,
                          child: tempSelectedState != null
                              ? ListView.builder(
                                  itemCount:
                                      _indianStates[tempSelectedState]!.length,
                                  itemBuilder: (context, index) {
                                    final city =
                                        _indianStates[tempSelectedState]![index];
                                    return ListTile(
                                      title: Text(city),
                                      trailing: tempSelectedCity == city
                                          ? Icon(
                                              Icons.check,
                                              color: Colors.green[800],
                                              size: 20,
                                            )
                                          : null,
                                      onTap: () {
                                        setState(() {
                                          tempSelectedCity = city;
                                        });
                                      },
                                    );
                                  },
                                )
                              : const Center(
                                  child: Text("Select a state first"),
                                ),
                        ),
                      ],
                    ),
                  ),

                  // Apply Button
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (tempSelectedState != null &&
                            tempSelectedCity != null) {
                          setState(() {
                            _selectedState = tempSelectedState!;
                            _selectedLocation = tempSelectedCity!;
                            _applyFilters();
                          });
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Apply Location",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Filter variables
  RangeValues _priceRange = const RangeValues(0, 2000);
  double _maxPrice = 2000;
  final Map<String, bool> _timeFilters = {
    'Morning': false,
    'Afternoon': false,
    'Evening': false,
    'Night': false,
  };

  // Updated category/sport filters with more sports
  final Map<String, bool> _sportFilters = {
    'Cricket': false,
    'Football': false,
    'Badminton': false,
    'Tennis': false,
    'Basketball': false,
    'Volleyball': false,
    'Table Tennis': false,
    'Swimming': false,
    'Gym': false,
    'Squash': false,
    'Hockey': false,
    'Rugby': false,
    'Baseball': false,
    'Boxing': false,
    'MMA': false,
    'Yoga': false,
    'Pilates': false,
    'Karate': false,
    'Judo': false,
    'Archery': false,
  };

  List<Turf> get _turfs => _turfService.turfs;

  @override
  void initState() {
    super.initState();

    // Initialize filtered turfs first
    _filteredTurfs = _turfs;

    // Set up listeners
    _turfService.addListener(_onDataChanged);
    _searchController.addListener(_searchTurfs);

    if (_turfs.isNotEmpty) {
      _maxPrice = _turfs
          .map((t) => t.price.toDouble())
          .reduce((a, b) => a > b ? a : b);
      _priceRange = RangeValues(0, _maxPrice);
    }

    // Apply filters after a delay to avoid build conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyFilters();
      _loadUserData();
    });
  }

  void _onDataChanged() {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _applyFilters();
          });
        }
      });
    }
  }

  void _searchTurfs() {
    final query = _searchController.text.toLowerCase();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          if (query.isEmpty) {
            _filteredTurfs = _turfs;
          } else {
            _filteredTurfs = _turfs
                .where(
                  (turf) =>
                      turf.name.toLowerCase().contains(query) ||
                      turf.location.toLowerCase().contains(query),
                )
                .toList();
          }
          _applyFilters();
        });
      }
    });
  }

  void _applyFilters() {
    if (!mounted) return;

    List<Turf> filtered = _turfService.turfs;

    // Apply search filter if any
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered
          .where(
            (turf) =>
                turf.name.toLowerCase().contains(query) ||
                turf.location.toLowerCase().contains(query),
          )
          .toList();
    }

    // Apply city filter
    filtered = filtered
        .where(
          (turf) => turf.city.toLowerCase() == _selectedLocation.toLowerCase(),
        )
        .toList();

    // Apply price range filter
    filtered = filtered
        .where(
          (turf) =>
              turf.price >= _priceRange.start && turf.price <= _priceRange.end,
        )
        .toList();

    // Apply time filters if any selected
    final selectedTimes = _timeFilters.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    if (selectedTimes.isNotEmpty) {
      filtered = filtered.where((turf) {
        if (selectedTimes.contains('Morning')) {
          return true;
        }
        if (selectedTimes.contains('Afternoon')) {
          return turf.price >= 400;
        }
        if (selectedTimes.contains('Evening')) {
          return turf.price >= 600;
        }
        if (selectedTimes.contains('Night')) {
          return turf.price >= 700 && turf.amenities.contains('Flood Lights');
        }
        return true;
      }).toList();
    }

    // Apply sport filters if any selected
    final selectedSports = _sportFilters.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    if (selectedSports.isNotEmpty) {
      filtered = filtered.where((turf) {
        // Check if turf supports any of the selected sports
        return selectedSports.any((sport) => turf.sports.contains(sport));
      }).toList();
    }

    // Apply offer filter
    if (_offerFilter) {
      // List of turf names that have offers (in real app, this would come from API)
      final offerTurfNames = [
        'Green Field Arena',
        'Elite Football Ground',
        'Shuttle Masters Academy',
        'City Sports Complex',
        'Royal Turf Ground',
      ];
      filtered = filtered
          .where((turf) => offerTurfNames.contains(turf.name))
          .toList();
    }

    if (mounted) {
      setState(() {
        _filteredTurfs = filtered;
      });
    }
  }

  void _resetFilters() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _priceRange = RangeValues(0, _maxPrice);
          _timeFilters.forEach((key, value) {
            _timeFilters[key] = false;
          });
          _sportFilters.forEach((key, value) {
            _sportFilters[key] = false;
          });
          _offerFilter = false;
          _applyFilters();
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _turfService.removeListener(_onDataChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Reduced Green Top Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.green[700]!, Colors.green[600]!],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Column(
                children: [
                  // Top Row: Location and Icons
                  Row(
                    children: [
                      // Location
                      InkWell(
                        onTap: _showLocationPicker,
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _selectedLocation,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            _selectedState,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.white.withOpacity(
                                                0.9,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Tournament Icon
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TournamentScreen(),
                              ),
                            );
                          },

                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                            ),
                            child: const Icon(
                              Icons.emoji_events_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),

                      // Admin Icon
                      if (_isPartner)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          child: IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AdminScreen(),
                                ),
                              );
                            },
                            icon: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.2),
                              ),
                              child: const Icon(
                                Icons.workspace_premium,
                                color: Color(0xFFFFD700), // Gold/Yellow
                                size: 20,
                              ),
                            ),
                          ),
                        ),

                      // Profile Icon
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: const Icon(
                            Icons.person_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfileScreen(),
                            ),
                          );
                          // Refresh data when returning from profile
                          _loadUserData();
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Welcome Text
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userName.isNotEmpty
                              ? "Hello, $_userName!"
                              : "Book Your Turf",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          "Play your favorite sport anytime",
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Search turfs by name or location...",
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.green[800],
                          size: 22,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.filter_list,
                            color: Colors.green[800],
                            size: 22,
                          ),
                          onPressed: () => _showFilterOptions(context),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 15,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),

            // Show only when filters are active
            if (_isFilterActive())
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${_filteredTurfs.length} turfs found",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[800],
                      ),
                    ),
                    TextButton(
                      onPressed: _resetFilters,
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: Text(
                        "Clear Filters",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.green[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Turf Cards
            Expanded(
              child: _filteredTurfs.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No turfs found",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            "Try adjusting your filters or search",
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      itemCount: _filteredTurfs.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            TurfCard(turf: _filteredTurfs[index]),
                            // Add subtle divider between cards (except last one)
                            if (index < _filteredTurfs.length - 1)
                              const Divider(
                                height: 20,
                                thickness: 0.5,
                                color: Color(0xFFEEEEEE),
                                indent: 20,
                                endIndent: 20,
                              ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isFilterActive() {
    return _priceRange.start > 0 ||
        _priceRange.end < _maxPrice ||
        _timeFilters.values.any((value) => value) ||
        _sportFilters.values.any((value) => value) ||
        _offerFilter;
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(20),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Filter Options",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Refine your search",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[100],
                          ),
                          child: const Icon(Icons.close, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Special Offers Filter
                          const Text(
                            "Special Offers",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          FilterChip(
                            label: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.local_offer, size: 16),
                                SizedBox(width: 6),
                                Text("Show Turfs with Offers"),
                              ],
                            ),
                            selected: _offerFilter,
                            onSelected: (selected) {
                              setState(() {
                                _offerFilter = selected;
                              });
                            },
                            backgroundColor: _offerFilter
                                ? Colors.red.shade50
                                : Colors.grey[100],
                            selectedColor: Colors.red,
                            labelStyle: TextStyle(
                              color: _offerFilter ? Colors.white : Colors.black,
                            ),
                          ),

                          const SizedBox(height: 25),

                          // Sport Category Filter
                          const Text(
                            "Sport Categories",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _sportFilters.keys.map((sport) {
                              final isSelected = _sportFilters[sport]!;
                              return ChoiceChip(
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getSportIcon(sport),
                                      size: 16,
                                      color: isSelected
                                          ? Colors.white
                                          : _getSportColor(sport),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(sport),
                                  ],
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _sportFilters[sport] = selected;
                                  });
                                },
                                backgroundColor: Colors.grey[100],
                                selectedColor: _getSportColor(sport),
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : _getSportColor(sport),
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 25),

                          // Price Range Filter
                          const Text(
                            "Price Range",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          RangeSlider(
                            values: _priceRange,
                            min: 0,
                            max: _maxPrice,
                            divisions: 20,
                            labels: RangeLabels(
                              "₹${_priceRange.start.round()}",
                              "₹${_priceRange.end.round()}",
                            ),
                            activeColor: Colors.green,
                            onChanged: (RangeValues values) {
                              setState(() {
                                _priceRange = values;
                              });
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("₹0"),
                              Text("₹${_maxPrice.toInt()}"),
                            ],
                          ),

                          const SizedBox(height: 25),

                          // Time Slot Filter
                          const Text(
                            "Preferred Time Slots",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _timeFilters.keys.map((timeSlot) {
                              final isSelected = _timeFilters[timeSlot]!;
                              return FilterChip(
                                label: Text(timeSlot),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _timeFilters[timeSlot] = selected;
                                  });
                                },
                                backgroundColor: Colors.grey[100],
                                selectedColor: Colors.green,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Apply & Clear Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _resetFilters();
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                          child: const Text(
                            "Clear All",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _applyFilters();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Apply Filters",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showTournamentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Upcoming Tournaments"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTournamentCard(
                  "Inter-College Cricket League",
                  "Dec 15-20, 2023",
                  "Green Field Arena",
                  "₹10,000 Prize",
                ),
                const SizedBox(height: 12),
                _buildTournamentCard(
                  "City Football Championship",
                  "Dec 22-24, 2023",
                  "Elite Football Ground",
                  "₹15,000 Prize",
                ),
                const SizedBox(height: 12),
                _buildTournamentCard(
                  "Badminton Singles Open",
                  "Jan 5-7, 2024",
                  "Shuttle Masters Academy",
                  "₹8,000 Prize",
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close tournament list
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text("🏏", style: TextStyle(fontSize: 32)),
                            SizedBox(width: 10),
                            Text("⚽", style: TextStyle(fontSize: 40)),
                            SizedBox(width: 10),
                            Text("🎾", style: TextStyle(fontSize: 32)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Coming Soon!",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1DB954),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Tournament registration will be available in our upcoming update. Stay tuned for more sports action!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text("🏀", style: TextStyle(fontSize: 24)),
                            SizedBox(width: 15),
                            Text("🏐", style: TextStyle(fontSize: 24)),
                            SizedBox(width: 15),
                            Text("🏸", style: TextStyle(fontSize: 24)),
                          ],
                        ),
                      ],
                    ),
                    actions: [
                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Awesome!",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF1DB954),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Register"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTournamentCard(
    String title,
    String date,
    String venue,
    String prize,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text("Date: $date", style: const TextStyle(fontSize: 12)),
          Text("Venue: $venue", style: const TextStyle(fontSize: 12)),
          Text("Prize: $prize", style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  // Helper method for sport icons in filter chips
  IconData _getSportIcon(String sport) {
    switch (sport.toLowerCase()) {
      case 'cricket':
        return Icons.sports_cricket;
      case 'football':
        return Icons.sports_soccer;
      case 'badminton':
        return Icons.sports_tennis;
      case 'tennis':
        return Icons.sports_tennis;
      case 'basketball':
        return Icons.sports_basketball;
      case 'volleyball':
        return Icons.sports_volleyball;
      case 'table tennis':
        return Icons.sports_tennis;
      case 'swimming':
        return Icons.pool;
      case 'gym':
        return Icons.fitness_center;
      case 'squash':
        return Icons.sports_tennis;
      case 'hockey':
        return Icons.sports_hockey;
      case 'rugby':
        return Icons.sports_rugby;
      case 'baseball':
        return Icons.sports_baseball;
      case 'boxing':
        return Icons.sports_mma;
      case 'mma':
        return Icons.sports_mma;
      case 'yoga':
        return Icons.self_improvement;
      case 'pilates':
        return Icons.accessibility_new;
      case 'karate':
        return Icons.sports_kabaddi;
      case 'judo':
        return Icons.sports_kabaddi;
      case 'archery':
        return Icons.arrow_circle_right;
      default:
        return Icons.sports;
    }
  }

  Color _getSportColor(String sport) {
    switch (sport.toLowerCase()) {
      case 'cricket':
        return Colors.green;
      case 'football':
        return Colors.blue;
      case 'badminton':
        return Colors.red;
      case 'tennis':
        return Colors.orange;
      case 'basketball':
        return Colors.purple;
      case 'volleyball':
        return Colors.teal;
      case 'table tennis':
        return Colors.pink;
      case 'swimming':
        return Colors.cyan;
      case 'gym':
        return Colors.purple;
      case 'squash':
        return Colors.amber;
      case 'hockey':
        return Colors.blueGrey;
      case 'rugby':
        return Colors.green;
      case 'baseball':
        return Colors.red;
      case 'boxing':
        return Colors.brown;
      case 'mma':
        return Colors.black;
      case 'yoga':
        return Colors.purpleAccent;
      case 'pilates':
        return Colors.cyan;
      case 'karate':
        return Colors.orangeAccent;
      case 'judo':
        return Colors.blueAccent;
      case 'archery':
        return Colors.deepOrange;
      default:
        return Colors.green;
    }
  }
}

class TurfCard extends StatefulWidget {
  final Turf turf;
  const TurfCard({super.key, required this.turf});

  @override
  State<TurfCard> createState() => _TurfCardState();
}

class _TurfCardState extends State<TurfCard> {
  int _currentImageIndex = 0;

  Future<void> _openMapLocation() async {
    final Uri uri = Uri.parse(widget.turf.mapLink);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open Google Maps")),
      );
    }
  }

  void _viewTurfDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TurfDetailsScreen(turf: widget.turf)),
    );
  }

  Widget _buildImageError() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
            SizedBox(height: 8),
            Text(
              "Image not available",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // Check if turf has an offer (for demo purposes)
  bool get _hasOffer {
    // For demo, let's show offer for specific turfs
    final offerTurfNames = [
      'Green Field Arena',
      'Elite Football Ground',
      'Shuttle Masters Academy',
      'Royal Turf Ground',
    ];
    return offerTurfNames.contains(widget.turf.name);
  }

  // Calculate offer price (for demo)
  double get _offerPrice {
    return widget.turf.price * 0.8; // 20% discount
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with error handling
          GestureDetector(
            onTap: _viewTurfDetails,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Container(
                height: 180,
                width: double.infinity,
                color: Colors.grey[100],
                child: Stack(
                  children: [
                    // Image with error handling
                    Builder(
                      builder: (context) {
                        final hasImages = widget.turf.images.isNotEmpty;

                        if (!hasImages) {
                          return _buildImageError();
                        }

                        return Image.network(
                          widget.turf.images[_currentImageIndex.clamp(
                            0,
                            widget.turf.images.length - 1,
                          )],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildImageError();
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        );
                      },
                    ),

                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),

                    // Rating badge - ALWAYS ON TOP LEFT
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.turf.rating.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Offer badge - PLACED BELOW RATING ON LEFT SIDE
                    if (_hasOffer)
                      Positioned(
                        top: 48, // Below the rating badge
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.red[600]!, Colors.red[400]!],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_offer,
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "20% OFF",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Distance badge - ALWAYS ON TOP RIGHT
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: _openMapLocation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.green,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${widget.turf.distance} km",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Turf Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and Location
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.turf.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.turf.location,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Price with offer
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: _hasOffer
                          ? [
                              // Original price with strikethrough
                              Text(
                                "₹${widget.turf.price}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[500],
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: Colors.red,
                                  decorationThickness: 2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              // Offer price
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "₹${_offerPrice.toInt()}",
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(left: 4),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red[50],
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: Colors.red[100]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      "SAVE ${(widget.turf.price - _offerPrice).toInt()}",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.red[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "/hour",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ]
                          : [
                              // Normal price without offer
                              Text(
                                "₹${widget.turf.price}",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                "/hour",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Sports Available with smaller chips
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Sports Available:",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: widget.turf.sports.map((sport) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _getSportColor(sport).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getSportColor(sport).withOpacity(0.2),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getSportIcon(sport),
                                size: 12,
                                color: _getSportColor(sport),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                sport,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _getSportColor(sport),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Book Button with special offer text
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingScreen(turf: widget.turf),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_month, size: 20),
                        const SizedBox(width: 10),
                        const Text(
                          "Book Now",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_hasOffer) const SizedBox(width: 4),
                        if (_hasOffer)
                          const Icon(Icons.bolt, size: 16, color: Colors.amber),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getSportColor(String sport) {
    switch (sport.toLowerCase()) {
      case 'cricket':
        return Colors.green;
      case 'football':
        return Colors.blue;
      case 'badminton':
        return Colors.red;
      case 'tennis':
        return Colors.orange;
      case 'basketball':
        return Colors.purple;
      case 'volleyball':
        return Colors.teal;
      case 'table tennis':
        return Colors.pink;
      case 'swimming':
        return Colors.cyan;
      case 'gym':
        return Colors.purple;
      case 'squash':
        return Colors.amber;
      case 'hockey':
        return Colors.blueGrey;
      case 'rugby':
        return Colors.green;
      case 'baseball':
        return Colors.red;
      case 'boxing':
        return Colors.brown;
      case 'mma':
        return Colors.black;
      case 'yoga':
        return Colors.purpleAccent;
      case 'pilates':
        return Colors.cyan;
      case 'karate':
        return Colors.orangeAccent;
      case 'judo':
        return Colors.blueAccent;
      case 'archery':
        return Colors.deepOrange;
      default:
        return Colors.green;
    }
  }

  IconData _getSportIcon(String sport) {
    switch (sport.toLowerCase()) {
      case 'cricket':
        return Icons.sports_cricket;
      case 'football':
        return Icons.sports_soccer;
      case 'badminton':
        return Icons.sports_tennis;
      case 'tennis':
        return Icons.sports_tennis;
      case 'basketball':
        return Icons.sports_basketball;
      case 'volleyball':
        return Icons.sports_volleyball;
      case 'table tennis':
        return Icons.sports_tennis;
      case 'swimming':
        return Icons.pool;
      case 'gym':
        return Icons.fitness_center;
      case 'squash':
        return Icons.sports_tennis;
      case 'hockey':
        return Icons.sports_hockey;
      case 'rugby':
        return Icons.sports_rugby;
      case 'baseball':
        return Icons.sports_baseball;
      case 'boxing':
        return Icons.sports_mma;
      case 'mma':
        return Icons.sports_mma;
      case 'yoga':
        return Icons.self_improvement;
      case 'pilates':
        return Icons.accessibility_new;
      case 'karate':
        return Icons.sports_kabaddi;
      case 'judo':
        return Icons.sports_kabaddi;
      case 'archery':
        return Icons.arrow_circle_right;
      default:
        return Icons.sports;
    }
  }
}
