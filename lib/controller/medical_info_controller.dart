import 'package:get/get.dart';

class MedicalInfoController extends GetxController {
  List<Map<String, String>> infoList = [];
  List<Map<String, String>> usefulLinks = [];
  List<Map<String, String>> helplines = [];
  
  @override
  void onInit() {
    super.onInit();
    fetchMedicalInfo();
    setupUsefulLinks();
    setupHelplines();
  }
  
  void fetchMedicalInfo() {
    infoList = [
      {
        'title': 'Understanding Hallucinations',
        'content': 'Hallucinations are perceptions in the absence of external stimulation. They can be linked to neurological, psychiatric, or substance-induced causes.'
      },
      {
        'title': 'Common Causes',
        'content': 'Conditions such as schizophrenia, bipolar disorder, severe depression, as well as sleep deprivation and substance abuse, may lead to hallucinations.'
      },
      {
        'title': 'When to Seek Help',
        'content': 'If hallucinations interfere with daily functioning, it is important to speak with a medical professional to identify any underlying conditions.'
      },
      {
        'title': 'Support Resources',
        'content': 'Reach out to local mental health services or trusted support networks if you experience distressing hallucinations.'
      },
      {
        'title': 'Preventative Measures',
        'content': 'Maintain regular sleep patterns, manage stress, and avoid substances that could trigger symptoms.'
      },
    ];
    update();
  }

  void setupUsefulLinks() {
    usefulLinks = [
      {
        'title': 'Cleveland Clinic - Hallucinations Overview',
        'url': 'https://my.clevelandclinic.org/health/symptoms/23350-hallucinations'
      },
      {
        'title': 'WebMD - Understanding Hallucinations',
        'url': 'https://www.webmd.com/schizophrenia/what-are-hallucinations'
      },
      {
        'title': 'Wikipedia - Hallucination',
        'url': 'https://en.wikipedia.org/wiki/Hallucination'
      },
      {
        'title': 'Cleveland Clinic - Auditory Hallucinations',
        'url': 'https://my.clevelandclinic.org/health/symptoms/23233-auditory-hallucinations'
      },
      {
        'title': 'Britannica - Hallucination',
        'url': 'https://www.britannica.com/science/hallucination'
      },
      {
        'title': 'WebMD - Conditions That Cause Hallucinations',
        'url': 'https://www.webmd.com/brain/ss/slideshow-conditions-that-cause-hallucinations'
      }
    ];
    update();
  }

  void setupHelplines() {
    helplines = [
      {
        'name': 'Vandrevala Foundation 24/7',
        'number': '+919999666555'
      },
      {
        'name': 'National Crisis Hotline',
        'number': '988'
      },
      {
        'name': 'SAMHSA National Helpline',
        'number': '1-800-662-4357'
      },
      {
        'name': 'National Alliance on Mental Illness (NAMI)',
        'number': '1-800-950-6264'
      },
      {
        'name': 'Crisis Text Line',
        'number': 'Text HOME to 741741'
      }
    ];
    update();
  }
}
