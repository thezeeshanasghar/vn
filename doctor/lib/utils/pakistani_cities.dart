class PakistaniCities {
  static const List<String> cities = [
    // Major Cities
    'Karachi', 'Lahore', 'Islamabad', 'Rawalpindi', 'Faisalabad', 'Multan', 'Gujranwala', 'Peshawar', 'Quetta', 'Sialkot',
    
    // Punjab Cities
    'Bahawalpur', 'Sargodha', 'Sahiwal', 'Okara', 'Rahim Yar Khan', 'Jhang', 'Sheikhupura', 'Vehari', 'Attock', 'Kot Addu',
    'Burewala', 'Kasur', 'Sadiqabad', 'Chiniot', 'Kamoke', 'Hafizabad', 'Kohat', 'Jacobabad', 'Shikarpur', 'Muzaffargarh',
    'Khanpur', 'Gojra', 'Bahawalnagar', 'Abbottabad', 'Muridke', 'Pakpattan', 'Kharian', 'Jhelum', 'Hasan Abdal', 'Kamalia',
    'Ahmadpur East', 'Kotri', 'Wah Cantonment', 'Vihari', 'New Mirpur', 'Daska', 'Mandi Bahauddin', 'Eminabad', 'Nawabshah',
    'Chishtian', 'Kot Abdul Malik', 'Haroonabad', 'Hasilpur', 'Ahmadpur Sial', 'Bhalwal', 'Sambrial', 'Pir Mahal', 'Umarkot',
    'Chakwal', 'Renala Khurd', 'Kohror Pakka', 'Duniya Pur', 'Dipalpur', 'Shujaabad', 'Sangla Hill', 'Fort Abbas', 'Chichawatni',
    'Bhakkar', 'Narowal', 'Khushab', 'Shahkot', 'Lodhran', 'Kot Mumin', 'Hujra Shah Muqim', 'Kabirwala', 'Nankana Sahib',
    'Dinga', 'Pattoki', 'Ghotki', 'Kot Radha Kishan', 'Haveli Lakha', 'Chak Jhumra', 'Toba Tek Singh', 'Naushahro Firoz',
    'Ali Pur', 'Kot Ghulam Muhammad', 'Ahmadpur East', 'Malakwal', 'Vehari', 'Jaranwala', 'Mianwali', 'Layyah', 'Karor Lal Esan',
    'Chunian', 'Baddomalhi', 'Qila Didar Singh', 'Arifwala', 'Gujrat', 'Bhera', 'Mitha Tiwana', 'Rojhan', 'Sambrial', 'Pir Mahal',
    
    // Sindh Cities
    'Hyderabad', 'Sukkur', 'Larkana', 'Nawabshah', 'Mirpur Khas', 'Shikarpur', 'Jacobabad', 'Khairpur', 'Dadu', 'Badin',
    'Tharparkar', 'Umerkot', 'Tando Allahyar', 'Tando Muhammad Khan', 'Sanghar', 'Naushahro Feroze', 'Matiari', 'Jamshoro',
    'Kashmore', 'Ghotki', 'Daharki', 'Kandhkot', 'Shahdadkot', 'Moro', 'Nawabshah', 'Kotri', 'Mirpur Mathelo', 'Tando Adam',
    'Sehwan', 'Mehrabpur', 'Khipro', 'Ranipur', 'Kot Diji', 'Garhi Khairo', 'Ratodero', 'Kandiaro', 'Kashmore', 'Tangwani',
    'Khanpur', 'Pir Jo Goth', 'Sinjhoro', 'Gambat', 'Kotri', 'Mirpur Khas', 'Umerkot', 'Tharparkar', 'Badin', 'Tando Allahyar',
    
    // KPK Cities
    'Mardan', 'Mingora', 'Kohat', 'Abbottabad', 'Dera Ismail Khan', 'Mansehra', 'Bannu', 'Timargara', 'Parachinar', 'Tank',
    'Hangu', 'Risalpur', 'Shabqadar', 'Charsadda', 'Karak', 'Bannu', 'Lakki Marwat', 'Tank', 'Dera Ismail Khan', 'Bajaur',
    'Mohmand', 'Khyber', 'Orakzai', 'Kurram', 'North Waziristan', 'South Waziristan', 'Swat', 'Buner', 'Shangla', 'Upper Dir',
    'Lower Dir', 'Malakand', 'Chitral', 'Kohistan', 'Battagram', 'Torghar', 'Haripur', 'Swabi', 'Nowshera', 'Charsadda',
    
    // Balochistan Cities
    'Turbat', 'Khuzdar', 'Chaman', 'Zhob', 'Gwadar', 'Dera Bugti', 'Usta Muhammad', 'Loralai', 'Pasni', 'Sibi', 'Ziarat',
    'Kalat', 'Mastung', 'Nushki', 'Kharan', 'Washuk', 'Awaran', 'Panjgur', 'Kech', 'Lasbela', 'Jhal Magsi', 'Killa Abdullah',
    'Killa Saifullah', 'Musakhel', 'Sherani', 'Barkhan', 'Kohlu', 'Dera Bugti', 'Jaffarabad', 'Nasirabad', 'Bolan', 'Sohbatpur',
    
    // AJK Cities
    'Muzaffarabad', 'Mirpur', 'Kotli', 'Bhimber', 'Rawalakot', 'Bagh', 'Haveli', 'Poonch', 'Sudhnuti', 'Neelum',
    
    // Gilgit-Baltistan Cities
    'Gilgit', 'Skardu', 'Hunza', 'Nagar', 'Ghanche', 'Shigar', 'Kharmang', 'Gultari', 'Ronde', 'Astore', 'Diamer',
  ];
  
  static List<String> getFilteredCities(String query) {
    if (query.isEmpty) return cities;
    return cities.where((city) => 
      city.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}
