import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/dua_item.dart';

class DuaScreen extends StatefulWidget {
  const DuaScreen({super.key});

  @override
  State<DuaScreen> createState() => _DuaScreenState();
}

class _DuaScreenState extends State<DuaScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'all';

  final List<DuaItem> duas = [
    // --- RAMADAN ---
    DuaItem(
      id: 'suhoor',
      category: 'ramadan',
      arabic: 'وَبِصَوْمِ غَدٍ نَّوَيْتُ مِنْ شَهْرِ رَمَضَانَ',
      transliteration: 'Wa bisawmi ghadin nawaytu min shahri Ramadan',
      translations: {
        'en': 'I intend to keep the fast for tomorrow in the month of Ramadan.',
        'tr': 'Ramazan ayında yarın oruç tutmaya niyet ettim.',
        'ar': 'نويت صيام غد من شهر رمضان.',
        'fr': 'J’ai l’intention de jeûner demain du mois de Ramadan.',
        'de': 'Ich beabsichtige, morgen im Monat Ramadan zu fasten.',
        'ru': 'Я намереваюсь поститься завтра в месяце Рамадан.',
        'ur': 'میں نے رمضان کے مہینے میں کل کے روزے کی نیت کی۔',
        'hi': 'मैं रमजान के महीने में कल का रोजा रखने की नीयत करता हूं।',
        'es': 'Tengo la intención de ayunar mañana en el mes de Ramadán.',
      },
    ),
    DuaItem(
      id: 'iftar',
      category: 'ramadan',
      arabic: 'اللَّهُمَّ لَكَ صُمْتُ وَعَلَى رِزْقِكَ أَفْطَرْتُ',
      transliteration: 'Allahumma laka sumtu wa ala rizqika aftartu',
      translations: {
        'en': 'O Allah, I fasted for You and I break my fast with Your provision.',
        'tr': 'Allah’ım senin için oruç tuttum ve senin rızkınla orucumu açtım.',
        'ar': 'اللهم لك صمت وعلى رزقك أفطرت.',
        'fr': 'Ô Allah, j’ai jeûné pour Toi et je romps mon jeûne avec Ta subsistance.',
        'de': 'O Allah, für Dich habe ich gefastet und mit Deiner Versorgung breche ich mein Fasten.',
        'ru': 'О Аллах, ради Тебя я постился и Твоим уделом разговляюсь.',
        'ur': 'اے اللہ، میں نے تیرے لیے روزہ رکھا اور تیرے ہی دیے ہوئے رزق سے افطار کیا۔',
        'hi': 'ऐ अल्लाह, मैंने तेरे लिए रोज़ा रखा और तेरे ही दिए रिज़्क़ से इफ़्तार किया।',
        'es': 'Oh Allah, por Ti he ayunado y con Tu provisión rompo mi ayuno.',
      },
    ),
    DuaItem(
      id: 'laylatul_qadr',
      category: 'ramadan',
      arabic: 'اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي',
      transliteration: 'Allahumma innaka afuwwun tuhibbul afwa fa’fu anni',
      translations: {
        'en': 'O Allah, You are Most Forgiving and love forgiveness, so forgive me.',
        'tr': 'Allah’ım, sen affedicisin, affetmeyi seversin, beni affet.',
        'ar': 'اللهم إنك عفو تحب العفو فاعف عني.',
        'fr': 'Ô Allah, Tu es Pardonneur et Tu aimes le pardon, alors pardonne-moi.',
        'de': 'O Allah, Du bist der Allverzeihende und liebst die Vergebung, so verzeih mir.',
        'ru': 'О Аллах, поистине, Ты — Прощающий, Ты любишь прощать, так прости же меня.',
        'ur': 'اے اللہ، تو معاف کرنے والا ہے اور معافی کو پسند کرتا ہے، پس مجھے معاف کر دے۔',
        'hi': 'ऐ अल्लाह, तू माफ करने वाला है और माफी पसंद करता है, मुझे माफ कर दे।',
        'es': 'Oh Allah, Tú eres el Perdonador y amas el perdón, perdóname.',
      },
    ),

    // --- DAILY ---
    DuaItem(
      id: 'morning',
      category: 'daily',
      arabic: 'اللَّهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا',
      transliteration: 'Allahumma bika asbahna wa bika amsayna',
      translations: {
        'en': 'O Allah, by You we enter the morning and by You we enter the evening.',
        'tr': 'Allah’ım seninle sabaha çıktık ve seninle akşama girdik.',
        'ar': 'اللهم بك أصبحنا وبك أمسينا.',
        'fr': 'Ô Allah, par Toi nous entrons dans le matin et le soir.',
        'de': 'O Allah, durch Dich sind wir in den Morgen und den Abend eingetreten.',
        'ru': 'О Аллах, благодаря Тебе мы дожили до утра и до вечера.',
        'ur': 'اے اللہ، تیرے ہی حکم سے ہم نے صبح کی اور تیرے ہی حکم سے شام کی۔',
        'hi': 'ऐ अल्लाह, तेरी ही कृपा से हमने सुबह की और तेरी ही कृपा से शाम की।',
        'es': 'Oh Allah, por Ti entramos en la mañana y en la tarde.',
      },
    ),
    DuaItem(
      id: 'evening',
      category: 'daily',
      arabic: 'اللَّهُمَّ بِكَ أَمْسَيْنَا وَبِكَ نَحْيَا',
      transliteration: 'Allahumma bika amsayna wa bika nahya',
      translations: {
        'en': 'O Allah, by You we enter the evening and by You we live.',
        'tr': 'Allah’ım seninle akşama girdik ve seninle yaşarız.',
        'ar': 'اللهم بك أمسينا وبك نحيا.',
        'fr': 'Ô Allah, par Toi nous entrons dans le soir et vivons.',
        'de': 'O Allah, durch Dich sind wir in den Abend eingetreten und leben wir.',
        'ru': 'О Аллах, благодаря Тебе мы дожили до вечера и живём.',
        'ur': 'اے اللہ، تیرے ہی حکم سے ہم نے شام کی اور ہم جیتے ہیں۔',
        'hi': 'ऐ अल्लाह, तेरी ही कृपा से हमने शाम की और हम जीते हैं।',
        'es': 'Oh Allah, por Ti entramos en la tarde y vivimos.',
      },
    ),
    DuaItem(
      id: 'bathroom_enter',
      category: 'daily',
      arabic: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْخُبُثِ وَالْخَبَائِثِ',
      transliteration: 'Allahumma inni a’udhu bika minal-khubthi wal-khaba’ith',
      translations: {
        'en': 'O Allah, I seek refuge in You from evil and impurities.',
        'tr': 'Allah’ım, pislikten ve cinlerin şerrinden sana sığınırım.',
        'ar': 'اللهم إني أعوذ بك من الخبث والخبائث.',
        'fr': 'Ô Allah, je cherche refuge contre le mal et les impuretés.',
        'de': 'O Allah, ich suche Zuflucht bei Dir vor dem Übel.',
        'ru': 'О Аллах, я прибегаю к Тебе от порочности и злых духов.',
        'ur': 'اے اللہ، میں خباثت اور گندگی سے تیری پناہ مانگتا ہوں۔',
        'hi': 'ऐ अल्लाह, मैं बुराई اور गंदगी से तेरी पनाह माँगता हूँ।',
        'es': 'Oh Allah, me refugio en Ti de la maldad.',
      },
    ),
    DuaItem(
      id: 'bathroom_exit',
      category: 'daily',
      arabic: 'غُفْرَانَكَ',
      transliteration: 'Ghufranak',
      translations: {
        'en': 'I seek Your forgiveness.',
        'tr': 'Bağışlanmanı dilerim.',
        'ar': 'غفرانك.',
        'fr': 'Je demande Ton pardon.',
        'de': 'Ich bitte um Deine Vergebung.',
        'ru': 'Прошу Твоего прощения.',
        'ur': 'تیری بخشش چاہتا ہوں۔',
        'hi': 'तेरी माफी चाहता हूं।',
        'es': 'Pido Tu perdón.',
      },
    ),
    DuaItem(
      id: 'wudu_start',
      category: 'daily',
      arabic: 'بِسْمِ اللَّهِ',
      transliteration: 'Bismillah',
      translations: {
        'en': 'In the name of Allah.',
        'tr': 'Allah’ın adıyla.',
        'ar': 'بسم الله.',
        'fr': 'Au nom d’Allah.',
        'de': 'Im Namen Allahs.',
        'ru': 'С именем Аллаха.',
        'ur': 'اللہ کے نام سے۔',
        'hi': 'अल्लाह के नाम से।',
        'es': 'En el nombre de Allah.',
      },
    ),
    DuaItem(
      id: 'wudu_end',
      category: 'daily',
      arabic: 'أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ',
      transliteration: 'Ashhadu an la ilaha illallah',
      translations: {
        'en': 'I bear witness that there is no god but Allah.',
        'tr': 'Allah’tan başka ilah olmadığına şahitlik ederim.',
        'ar': 'أشهد أن لا إله إلا الله.',
        'fr': 'Je témoigne qu’il n’y a de divinité qu’Allah.',
        'de': 'Ich bezeuge, dass es keinen Gott außer Allah gibt.',
        'ru': 'Я свидетельствую, что нет бога кроме Аллаха.',
        'ur': 'میں گواہی دیتا ہوں کہ اللہ کے سوا کوئی معبود نہیں۔',
        'hi': 'मैं गवाही देता हूं कि अल्लाह के सिवा कोई माबूद नहीं।',
        'es': 'Doy testimonio de que no hay más dios que Allah.',
      },
    ),
    DuaItem(
      id: 'sneeze',
      category: 'daily',
      arabic: 'الْحَمْدُ لِلَّهِ',
      transliteration: 'Alhamdulillah',
      translations: {
        'en': 'All praise is for Allah.',
        'tr': 'Hamd Allah’a mahsustur.',
        'ar': 'الحمد لله.',
        'fr': 'Louange à Allah.',
        'de': 'Alles Lob gebührt Allah.',
        'ru': 'Хвала Аллаху.',
        'ur': 'تمام تعریفیں اللہ کے لیے ہیں۔',
        'hi': 'सब तारीफ अल्लाह के लिए है।',
        'es': 'Toda la alabanza es para Allah.',
      },
    ),
    DuaItem(
      id: 'protection1',
      category: 'daily',
      arabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
      transliteration: 'A’udhu bikalimatillahit-tammati min sharri ma khalaq',
      translations: {
        'en': 'I seek refuge in the perfect words of Allah from the evil of what He has created.',
        'tr': 'Yarattıklarının şerrinden Allah’ın tam kelimelerine sığınırım.',
        'ar': 'أعوذ بكلمات الله التامات من شر ما خلق.',
        'fr': 'Je cherche refuge dans les paroles parfaites d’Allah contre le mal.',
        'de': 'Ich suche Zuflucht bei den vollkommenen Worten Allahs.',
        'ru': 'Прибегаю к совершенным словам Аллаха от зла того, что Он создал.',
        'ur': 'میں اللہ کے مکمل کلمات کی پناہ مانگتا ہوں اس کی مخلوق کے شر سے۔',
        'hi': 'मैं अल्लाह के शब्दों की शरण लेता हूँ उसकी रचना की बुराई से।',
        'es': 'Me refugio en las palabras perfectas de Allah del mal creado.',
      },
    ),
    DuaItem(
      id: 'protection2',
      category: 'daily',
      arabic: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ',
      transliteration: 'Bismillahil-ladhi la yadurru ma’asmihi shay’un',
      translations: {
        'en': 'In the name of Allah, nothing can harm with His name.',
        'tr': 'Allah’ın adıyla, O’nun adı varken hiçbir şey zarar veremez.',
        'ar': 'بسم الله الذي لا يضر مع اسمه شيء.',
        'fr': 'Au nom d’Allah, rien ne peut nuire en présence de Son nom.',
        'de': 'Im Namen Allahs, mit dessen Namen nichts schaden kann.',
        'ru': 'С именем Аллаха, с именем Которого ничто не причинит вреда.',
        'ur': 'اللہ کے نام سے، جس کے نام کی برکت سے کوئی چیز نقصان نہیں پہنچاتی۔',
        'hi': 'अल्लाह के नाम से, जिसके नाम से कोई चीज़ नुकसान नहीं पहुँचाती।',
        'es': 'En el nombre de Allah, con Su nombre nada puede dañar.',
      },
    ),

    // --- SLEEP ---
    DuaItem(
      id: 'sleep',
      category: 'sleep',
      arabic: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
      transliteration: 'Bismika Allahumma amutu wa ahya',
      translations: {
        'en': 'In Your name O Allah, I die and I live.',
        'tr': 'Allah’ım senin adınla ölür ve dirilirim.',
        'ar': 'باسمك اللهم أموت وأحيا.',
        'fr': 'En Ton nom, ô Allah, je meurs et je vis.',
        'de': 'In Deinem Namen, o Allah, sterbe ich und lebe ich.',
        'ru': 'С Твоим именем, о Аллах, я умираю и оживаю.',
        'ur': 'اے اللہ، تیرے نام کے ساتھ میں مرتا اور جیتا ہوں۔',
        'hi': 'ऐ अल्लाह, तेरे नाम से मैं मरता और जीता हूँ।',
        'es': 'En Tu nombre, oh Allah, muero y vivo.',
      },
    ),
    DuaItem(
      id: 'wakeup',
      category: 'sleep',
      arabic: 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا',
      transliteration: 'Alhamdu lillahil-ladhi ahyana',
      translations: {
        'en': 'All praise is for Allah who gave us life after causing us to die.',
        'tr': 'Bizi öldürdükten sonra dirilten Allah’a hamdolsun.',
        'ar': 'الحمد لله الذي أحيانا بعد ما أماتنا.',
        'fr': 'Louange à Allah qui nous a rendu la vie après nous avoir fait mourir.',
        'de': 'Alles Lob gebührt Allah, der uns wiederbelebt hat.',
        'ru': 'Хвала Аллаху, Который оживил нас после того, как умертвил.',
        'ur': 'شکر ہے اس اللہ کا جس نے ہمیں مارنے کے بعد زندہ کیا۔',
        'hi': 'शुक्र है उस अल्लाह का जिसने हमें मारने के बाद ज़िंदा किया।',
        'es': 'Alabado sea Allah que nos dio la vida tras la muerte.',
      },
    ),

    // --- FOOD ---
    DuaItem(
      id: 'before_eating',
      category: 'food',
      arabic: 'بِسْمِ اللَّهِ',
      transliteration: 'Bismillah',
      translations: {
        'en': 'In the name of Allah.',
        'tr': 'Allah’ın adıyla.',
        'ar': 'بسم الله.',
        'fr': 'Au nom d’Allah.',
        'de': 'Im Namen Allahs.',
        'ru': 'С именем Аллаха.',
        'ur': 'اللہ کے نام سے۔',
        'hi': 'अल्लाह के नाम से।',
        'es': 'En el nombre de Allah.',
      },
    ),
    DuaItem(
      id: 'after_eating',
      category: 'food',
      arabic: 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا',
      transliteration: 'Alhamdu lillahil-ladhi at’amana wa saqana',
      translations: {
        'en': 'All praise is for Allah who fed us and gave us drink.',
        'tr': 'Bizi yediren ve içiren Allah’a hamdolsun.',
        'ar': 'الحمد لله الذي أطعمنا وسقانا.',
        'fr': 'Louange à Allah qui nous a nourris et abreuvés.',
        'de': 'Alles Lob gebührt Allah, der uns gespeist und getränkt hat.',
        'ru': 'Хвала Аллаху, Который накормил и напоил нас.',
        'ur': 'سب تعریفیں اللہ کے لیے ہیں جس نے ہمیں کھلایا اور پلایا۔',
        'hi': 'सब तारीफ अल्लाह के लिए है जिसने हमें खिलाया और पिलाया।',
        'es': 'Alabado sea Allah que nos alimentó y nos dio de beber.',
      },
    ),

    // --- HOME ---
    DuaItem(
      id: 'leave_home',
      category: 'home',
      arabic: 'بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ',
      transliteration: 'Bismillah tawakkaltu ala Allah',
      translations: {
        'en': 'In the name of Allah, I trust in Allah.',
        'tr': 'Allah’ın adıyla, Allah’a tevekkül ettim.',
        'ar': 'بسم الله توكلت على الله.',
        'fr': 'Au nom d’Allah, je place ma confiance en Allah.',
        'de': 'Im Namen Allahs, ich vertraue auf Allah.',
        'ru': 'С именем Аллаха, я уповаю на Аллаха.',
        'ur': 'اللہ کے نام سے، میں نے اللہ پر توکل کیا۔',
        'hi': 'अल्लाह के नाम से, मैंने अल्लाह पर भरोसा किया।',
        'es': 'En el nombre de Allah, confío en Allah.',
      },
    ),

    // --- TRAVEL ---
    DuaItem(
      id: 'travel',
      category: 'travel',
      arabic: 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا',
      transliteration: 'Subhanalladhi sakhkhara lana hadha',
      translations: {
        'en': 'Glory is to Him who has subjected this to us.',
        'tr': 'Bunu bize boyun eğdiren Allah’ı tesbih ederiz.',
        'ar': 'سبحان الذي سخر لنا هذا.',
        'fr': 'Gloire à Celui qui nous a soumis cela.',
        'de': 'Gepriesen sei Er, der uns dies dienstbar gemacht hat.',
        'ru': 'Пречист Тот, Кто подчинил нам это.',
        'ur': 'پاک ہے وہ ذات جس نے اسے ہمارے قابو میں کر دیا۔',
        'hi': 'पावन ہے وہ جس نے اسے ہمارے قبضے میں کر دیا۔',
        'es': 'Gloria a Quien nos ha sometido esto.',
      },
    ),

    // --- GENERAL / CORE ---
    DuaItem(
      id: 'forgiveness',
      category: 'general',
      arabic: 'أَسْتَغْفِرُ اللَّهَ',
      transliteration: 'Astaghfirullah',
      translations: {
        'en': 'I seek forgiveness from Allah.',
        'tr': 'Allah’tan bağışlanma dilerim.',
        'ar': 'أستغفر الله.',
        'fr': 'Je demande pardon à Allah.',
        'de': 'Ich bitte Allah um Vergebung.',
        'ru': 'Я прошу прощения у Аллаха.',
        'ur': 'میں اللہ سے معافی مانگتا ہوں۔',
        'hi': 'मैं अल्लाह से माफी मांगता हूं।',
        'es': 'Pido perdón a Allah.',
      },
    ),
    DuaItem(
      id: 'anxiety',
      category: 'general',
      arabic: 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ',
      transliteration: 'Allahumma inni a’udhu bika minal-hammi wal-hazan',
      translations: {
        'en': 'O Allah, I seek refuge in You from anxiety and sorrow.',
        'tr': 'Allah’ım, keder ve üzüntüden sana sığınırım.',
        'ar': 'اللهم إني أعوذ بك من الهم والحزن.',
        'fr': 'Ô Allah, je cherche refuge en Toi contre l’anxiété et la tristesse.',
        'de': 'O Allah, ich suche Zuflucht bei Dir vor Sorgen und Trauer.',
        'ru': 'О Аллах, я прибегаю к Тебе от беспокойства и грусти.',
        'ur': 'اے اللہ، میں پریشانی اور غم سے تیری پناہ مانگتا ہوں۔',
        'hi': 'ऐ अल्लाह, मैं चिंता और दुख से तेरी पनाह मांगता हूं।',
        'es': 'Oh Allah, me refugio en Ti de la ansiedad y la tristeza.',
      },
    ),
    DuaItem(
      id: 'anger',
      category: 'general',
      arabic: 'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ',
      transliteration: 'A’udhu billahi minash-shaytanir-rajim',
      translations: {
        'en': 'I seek refuge in Allah from Satan.',
        'tr': 'Kovulmuş şeytandan Allah’a sığınırım.',
        'ar': 'أعوذ بالله من الشيطان الرجيم.',
        'fr': 'Je cherche refuge en Allah contre Satan.',
        'de': 'Ich suche Zuflucht bei Allah vor dem verfluchten Satan.',
        'ru': 'Прибегаю к защите Аллаха от проклятого шайтана.',
        'ur': 'میں شیطان مردود سے اللہ کی پناہ مانگتا ہوں۔',
        'hi': 'میں شیطان سے اللہ کی پناہ مانگتا ہوں۔',
        'es': 'Me refugio en Allah de Satanás.',
      },
    ),
    DuaItem(
      id: 'gratitude',
      category: 'general',
      arabic: 'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ',
      transliteration: 'Allahumma a’inni ala dhikrika wa shukrika',
      translations: {
        'en': 'O Allah, help me remember You and thank You.',
        'tr': 'Allah’ım seni anmamda ve şükretmemde bana yardım et.',
        'ar': 'اللهم أعني على ذكرك وشكرك.',
        'fr': 'Ô Allah, aide-moi à Te mentionner et Te remercier.',
        'de': 'O Allah, hilf mir Deiner zu gedenken und Dir zu danken.',
        'ru': 'О Аллах, помоги мне поминать Тебя и благодарить Тебя.',
        'ur': 'اے اللہ، اپنے ذکر اور شکر پر میری مدد فرما۔',
        'hi': 'ऐ अल्लाह, अपने ज़िक्र और शुक्र पर मेरी मदद फरमा।',
        'es': 'Oh Allah, ayúdame a recordarte y agradecerte.',
      },
    ),
    DuaItem(
      id: 'guidance',
      category: 'general',
      arabic: 'اللَّهُمَّ اهْدِنِي',
      transliteration: 'Allahumma ihdini',
      translations: {
        'en': 'O Allah, guide me.',
        'tr': 'Allah’ım bana hidayet ver.',
        'ar': 'اللهم اهدني.',
        'fr': 'Ô Allah, guide-moi.',
        'de': 'O Allah, leite mich recht.',
        'ru': 'О Аллах, наставь меня на прямой путь.',
        'ur': 'اے اللہ، مجھے ہدایت دے۔',
        'hi': 'ऐ अल्लाह, मुझे हिदायत दे।',
        'es': 'Oh Allah, guíame.',
      },
    ),
    DuaItem(
      id: 'rizq',
      category: 'general',
      arabic: 'اللَّهُمَّ ارْزُقْنِي رِزْقًا طَيِّبًا',
      transliteration: 'Allahumma-rzuqni rizqan tayyiban',
      translations: {
        'en': 'O Allah, grant me good sustenance.',
        'tr': 'Allah’ım bana helal ve güzel rızık ver.',
        'ar': 'اللهم ارزقني رزقاً طيباً.',
        'fr': 'Ô Allah, accorde-moi une bonne subsistance.',
        'de': 'O Allah, gewähre mir gute Versorgung.',
        'ru': 'О Аллах, даруй мне благую пищу.',
        'ur': 'اے اللہ، مجھے پاکیزہ رزق عطا فرما۔',
        'hi': 'ऐ अल्लाह, मुझे पाकीज़ा रिज़्क़ अता फरमा।',
        'es': 'Oh Allah, concédeme un buen sustento.',
      },
    ),
  ];

  String get _langCode {
    final code = Localizations.localeOf(context).languageCode;
    const supported = ['tr', 'ar', 'fr', 'de', 'ru', 'ur', 'hi', 'es'];
    return supported.contains(code) ? code : 'en';
  }

  bool get _isRTL => _langCode == 'ar' || _langCode == 'ur';

  Map<String, String> get _uiText {
    switch (_langCode) {
      case 'tr': return {'title': 'Dualar', 'search': 'Dua ara...', 'all': 'Tümü', 'ramadan': 'Ramazan', 'daily': 'Günlük', 'sleep': 'Uyku', 'food': 'Yemek', 'home': 'Ev', 'travel': 'Yolculuk', 'general': 'Genel', 'copied': 'Kopyalandı', 'translation': 'Anlam', 'transliteration': 'Okunuş', 'empty': 'Sonuç bulunamadı'};
      case 'ar': return {'title': 'الأدعية', 'search': 'ابحث...', 'all': 'الكل', 'ramadan': 'رمضان', 'daily': 'يومي', 'sleep': 'النوم', 'food': 'الطعام', 'home': 'المنزل', 'travel': 'السفر', 'general': 'عام', 'copied': 'تم النسخ', 'translation': 'المعنى', 'transliteration': 'النطق', 'empty': 'لا توجد نتائج'};
      case 'ur': return {'title': 'دعائیں', 'search': 'تلاش کریں...', 'all': 'سب', 'ramadan': 'رمضان', 'daily': 'روزانہ', 'sleep': 'نیند', 'food': 'کھانا', 'home': 'گھر', 'travel': 'سفر', 'general': 'عام', 'copied': 'کاپی ہو گیا', 'translation': 'ترجمہ', 'transliteration': 'تلفظ', 'empty': 'کوئی نتیجہ نہیں ملا'};
      case 'hi': return {'title': 'दुआएं', 'search': 'खोजें...', 'all': 'सभी', 'ramadan': 'रमजान', 'daily': 'दैनिक', 'sleep': 'नींद', 'food': 'भोजन', 'home': 'घर', 'travel': 'यात्रा', 'general': 'सामान्य', 'copied': 'कॉपी किया गया', 'translation': 'अनुवाद', 'transliteration': 'लिप्यंतरण', 'empty': 'कोई परिणाम नहीं मिला'};
      case 'de': return {'title': 'Bittgebete', 'search': 'Suche...', 'all': 'Alle', 'ramadan': 'Ramadan', 'daily': 'Täglich', 'sleep': 'Schlaf', 'food': 'Essen', 'home': 'Zuhause', 'travel': 'Reise', 'general': 'Allgemein', 'copied': 'Kopiert', 'translation': 'Bedeutung', 'transliteration': 'Umschrift', 'empty': 'Keine Ergebnisse'};
      case 'ru': return {'title': 'Дуа', 'search': 'Поиск...', 'all': 'Все', 'ramadan': 'Рамадан', 'daily': 'Ежедневно', 'sleep': 'Сон', 'food': 'Еда', 'home': 'Дом', 'travel': 'Путешествие', 'general': 'Общее', 'copied': 'Скопировано', 'translation': 'Перевод', 'transliteration': 'Транслитерация', 'empty': 'Ничего не найдено'};
      case 'es': return {'title': 'Súplicas', 'search': 'Buscar...', 'all': 'Todo', 'ramadan': 'Ramadán', 'daily': 'Diario', 'sleep': 'Sueño', 'food': 'Comida', 'home': 'Hogar', 'travel': 'Viaje', 'general': 'General', 'copied': 'Copiado', 'translation': 'Traducción', 'transliteration': 'Transliteración', 'empty': 'No hay resultados'};
      case 'fr': return {'title': 'Douas', 'search': 'Rechercher...', 'all': 'Tout', 'ramadan': 'Ramadan', 'daily': 'Quotidien', 'sleep': 'Sommeil', 'food': 'Repas', 'home': 'Maison', 'travel': 'Voyage', 'general': 'Général', 'copied': 'Copié', 'translation': 'Traduction', 'transliteration': 'Translittération', 'empty': 'Aucun résultat'};
      default: return {'title': 'Duas', 'search': 'Search dua...', 'all': 'All', 'ramadan': 'Ramadan', 'daily': 'Daily', 'sleep': 'Sleep', 'food': 'Food', 'home': 'Home', 'travel': 'Travel', 'general': 'General', 'copied': 'Copied', 'translation': 'Translation', 'transliteration': 'Transliteration', 'empty': 'No results found'};
    }
  }

  List<String> get _categories => ['all', 'ramadan', 'daily', 'sleep', 'food', 'home', 'travel', 'general'];

  @override
  Widget build(BuildContext context) {
    final t = _uiText;
    final filtered = duas.where((dua) {
      final matchesCategory = _selectedCategory == 'all' || dua.category == _selectedCategory;
      final query = _searchQuery.trim().toLowerCase();
      return matchesCategory && (query.isEmpty || dua.arabic.contains(query) || dua.transliteration.toLowerCase().contains(query) || dua.translationFor(_langCode).toLowerCase().contains(query));
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: Text(t['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: t['search'],
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(t[cat] ?? cat),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                    selectedColor: Colors.green,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: filtered.isEmpty
                  ? Center(child: Text(t['empty']!))
                  : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                itemBuilder: (context, index) => _duaCard(filtered[index], t),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _duaCard(DuaItem dua, Map<String, String> t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(t[dua.category] ?? dua.category, style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: "${dua.arabic}\n\n${dua.transliteration}\n\n${dua.translationFor(_langCode)}"));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t['copied']!)));
                },
                icon: const Icon(Icons.copy_rounded, size: 20, color: Colors.grey),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            dua.arabic,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.6, color: Color(0xFF1B5E20)),
          ),
          const Divider(height: 32),
          _contentSection(t['transliteration']!, dua.transliteration, isItalic: true),
          const SizedBox(height: 16),
          _contentSection(t['translation']!, dua.translationFor(_langCode), alignRight: _isRTL),
        ],
      ),
    );
  }

  Widget _contentSection(String label, String content, {bool isItalic = false, bool alignRight = false}) {
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green)),
        const SizedBox(height: 4),
        Text(
          content,
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
          style: TextStyle(fontSize: 15, height: 1.4, fontStyle: isItalic ? FontStyle.italic : FontStyle.normal, color: Colors.black87),
        ),
      ],
    );
  }
}