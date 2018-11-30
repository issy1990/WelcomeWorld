//
//  Constrant.h
//  workruit
//
//  Created by Admin on 9/29/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#ifndef Constrant_h
#define Constrant_h
#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

//Colors
#define WarningMessageColor [UIColor colorWithRed:254/255.0 green:78/255.0 blue:75/255.0 alpha:1.0]
#define DividerLineColor [UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1.0]// e4e4e4
#define placeHolderColor [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:205.0/255.0 alpha:1.0] // C7C7CD
#define MainTextColor [UIColor colorWithRed:47.0/255.0 green:47.0/255.0 blue:47.0/255.0 alpha:1.0] //2f2f2f

//Fonts
#define GlobalFontRegular @"SourceSansPro-Regular"
#define GlobalFontBold @"SourceSansPro-Bold"
#define GlobalFontSemibold @"SourceSansPro-Semibold"

#define USERNAME @"admin"
#define PASSWORD @"workruit$"



#define CELL_HEIGHT 55

#define NOTIFICATION_AUTO_LOGOUT @"Notification_Auto_Logout"
#define CRITCAL_UPDATE_CATEGORY @"Notification_Critical_Update"


#define DIDRECEIVEMESSAGEHANDLER @"DIDRECEIVEMESSAGEHANDLER"
#define DIDRECEIVEPRESENCEEVENT @"DIDRECEIVEPRESENCEEVENT"
#define DIDRECEIVESTATUS @"DIDRECEIVESTATUS"
#define DIDRECIVEHISTORYWITHDATA @"DIDRECIVEHISTORYWITHDATA"
#define RELOADCONVERSATIONLIST @"RELOADCONVERSATIONSLIST"
#define RELOADJOBSLIST @"RELOADJOBSLIST"
#define DISMISSNOTIFICATIONFROMVIEW @"dismissNotificationFromView"
#define UPDATEDATANOTIFICATION @"updateDataNotification"

//Notification Center Keys
#define EMAIL_VERIFICATION_SERVICE_NOTIFIER @"EmailVerifyServiceNotifier"
#define RECEIVE_LOGOUT_NOTIFICATION_NAME_KEY @"receiveLogutNotificationNameKey"
#define DIDRECIVE_REMOTE_NOTIFICATION @"didReciveRemoteNotification"
#define DIDRECIVE_REMOTE_NOTIFICATION_ON_CLICK @"didReciveRemoteNotificationOnClick"

#define STARTCONVERSATION_NOTIFICATION @"startConversationNotification"
#define APPCRITICAL_UPDATE_NOTIFICATION @"CriticalUpdateNotification"
#define SAVE_LOCAL_OBJECTS_NOTIFICATION @"SaveLocalObjectNotification"
#define APP_CRITICAL_UPDATE_OS_VERSION @"CriticalUpdateVersion"
#define APPCRITICAL_UPDATE_NOTIFICATION_FLAG @"CriticalUpdateNotificationFlag"
#define APP_UPDATE_TITLE @"New version available"
#define APP_UPDATE_MESSAGE @"Bug Fixes and UI Enhancements. Please update your App."

#define APP_DEFAULT_MESSAGE @"Hey, thanks for joining Workruit. I'm Manikanth, Founder and CEO, and here to make sure you find the right job. Swipe right to apply, left otherwise. Click to view more information."

#define MAIN_STORYBOARD @"Main"
#define APPLICANT_STORYBOARD @"Applicant"
#define COMPANY_STORYBOARD @"Company"
#define ENCRYPTION_KEY @"605bd70efed2c6374823b54bbc560b58"



//-----DEV-------//
//#define API_BASE_URL  @"https://devapi.workruit.com/api"
//#define IMAGE_BASE_URL @"https://devimages.workruit.com/resources"

//-----PRODCUTION-------//
//#define API_BASE_URL  @"https://apiv2.workruit.com/api"
//#define IMAGE_BASE_URL @"https://apiv2images.workruit.com/resources"
//#define AS3BUCKET_NAME @"workruit-resume"
//#define Other_Company_Jobs @"https://apiv2.workruit.com/admin/external/jobs?"
//#define View_AppliedJobs @"https://apiv2.workruit.com/api"
//# define MIX_PANEL @"5938f26780227e06df1a67e1dded9409"     // Production Key
//#define NSLog if(0) NSLog

//----SERVICE URL ENCRIPTED----//
#define API_BASE_URL  @"https://devsecureapi.workruit.com/api"
#define IMAGE_BASE_URL @"https://devimages.workruit.com/resources"
#define AS3BUCKET_NAME @"workruit-resume-dev"
#define Other_Company_Jobs @"https://devapi.workruit.com/admin/external/jobs?"
#define View_AppliedJobs @"https://devapi.workruit.com/api"
#define MIX_PANEL  @"da01d311ede2a43d08946ef5725c5410"        // Development Key
//#define NSLog if(1) NSLog
//-----PRODCUTION TEMP-------//
//#define API_BASE_URL  @"https://prodapi.workruit.com/api"
//#define IMAGE_BASE_URL @"https://prodimages.workruit.com/resources"


//-----STAGGING TEMP-------//
//#define API_BASE_URL  @"https://stageapi.workruit.com/api"
//#define IMAGE_BASE_URL @"https://stageimages.workruit.com/resources"
//#define AS3BUCKET_NAME @"workruit-resume-stage"
//#define Other_Company_Jobs @"https://stageapi.workruit.com/admin/external/jobs?"
//#define View_AppliedJobs @"https://stageapi.workruit.com/api"
//#define MIX_PANEL  @"da01d311ede2a43d08946ef5725c5410"        // Development Key
//#define NSLog if(1) NSLog

#define MASTER_DATA_API @"/masterData"
#define RECRUITER_SIGNUP_API @"/recruiterSignup"
#define SAVE_COMAPNY_API @"/saveCompany"
#define UPLOAD_COMPANY_LOGO_API @"/uploadCompanyLogo"
#define UPLOAD_PROFILE_PIC @"/uploadProfilePic"
#define GET_LOGIN_STATUS @"/getUserLoginStatus"
#define SECURED_RECRUTER_SIGNUP @"/securedRecruiterSignup"
#define UPDATE_REGID @"/updateRegId"
#define VERSION_URL @"/version"
#define HTTP_GET @"GET"
#define HTTP_POST @"POST"


//PARAMS KEYS
#define JOB_ROLE_ID_KEY @"jobRoleId"
#define FIRST_NAME_KEY @"firstname"
#define LAST_NAME_KEY @"lastname"
#define EMAIL_KEY @"email"
#define TELE_PHONE_KEY @"telephone"
#define PASSWORD_KEY @"password"
#define RECRUITER_COMPANY_NAME_KEY @"recruiterCompanyName"
#define JOB_ROLE_KEY @"jobRole"
#define DEVICE_TYPE_KEY @"deviceType"
#define REGD_ID_KEY @"regdId"
#define COMAPANY_SIZE_KEY @"company_size"
#define COMAPANY_SIZE_ID_KEY @"company_size_id"
#define COMAPANY_WEB_SITE_KEY @"company_website_url"
#define STATUS_KEY @"status"
#define SUCCESS_KEY @"success"
#define FAILD_KEY @"failed"
#define APPLICANT_OBJECT_PARAMS @"applicantObject"
#define COMPANY_OBJECT_PARAMS @"companyObject"

#define NETWORK_ERROR_MESSAGE @"Something went wrong with your network. Please make sure you have an active internet connection."
#define NETWORK_ERROR_TITLE  @"Network Error"

#define COMPANY_NAME_KEY @"companyName"
#define COMPANY_WEBSITE_KEY @"website"
#define USER_ID_KEY @"userId"
#define USER_JOB_ROLE_KEY @"userJobRole"
#define SIZE_KEY @"size"
#define CSID_KEY @"csId"
#define LOCATION_KEY @"location"
#define LOCATION_NAME_KEY @"location_name"
#define LOCATION_ID_KEY @"locationId"
#define COMAPNY_INDUSTRIES_SET_KEY @"companyIndustriesSet"
#define COMAPNY_SOCIAL_MEDIA_LINKS_KEY @"companySocialMediaLinks"
#define COMPANY_FOUNDED_YEAR_KEY @"establishedDate"
#define COMPANY_DESCRIPTION @"about"
#define FIRSTTIMECALLCONVERSATIONS @"FirstTimeCallConverSations"
#define USERJOBSFORAPPLICANTARRAY @"UserJobsForApplicant"
#define PROFILEFORJOBARRAY @"profilesForJobsArray"
#define INTRESTEDLISTARRAY @"IntrestedListArray"
#define  ACCOUNTS_JSON_DATA @"accounts_json_data"
#define JOBSLISTARRAY @"jobsListArray"

//Applicant Side MixPanel Event Names


#define APPLICANT_SIGNUP_BASIC @"AS - Basic"
#define APPLICANT_SIGNUP_OTP  @"AS - OTP"
#define APPLICANT_SIGNUP_PREF  @"AS - Pref"
#define APPLICANT_SIGNUP_PREFNOEXP  @"AS-Pref-NoExp"
#define APPLICANT_SIGNUP_PREFEXP  @"AS-Pref-Exp"
#define APPLICANT_SIGNUP_JOBFUNCTION  @"AS - Job Function"
#define APPLICANT_SIGNUP_SKILLS  @"AS - Skills"
#define APPLICANT_SIGNUP_EXPERIENCE @"AS - Exp"
#define APPLICANT_SIGNUP_EXPSKIP  @"AS - Exp - Skip"
#define APPLICANT_SIGNUP_EDUCATION  @"AS - Edu"
#define APPLICANT_SIGNUP_EDUSKIP  @"AS - Edu - Skip"
#define APPLICANT_SIGNUP_ABOUT  @"AS - About"
#define APPLICANT_SIGNUP_ABOUTSKIP  @"AS - About - Skip"
#define APPLICANT_SIGNUP_PROFILE_SUCESS  @"AS - Home (Profile - Success)"
#define APPLICANT_SIGNUP_PROFILE_INCOMPLETE  @"AS - Home (Profile Incomplete)"

#define APPLICANT_JOBS_NOJOBS  @"AJ - Com No Jobs"
#define APPLICANT_JOBS_NOJOBS_UPDATEPROFILE  @"AJ - Com No Jobs - Update Profile"
#define APPLICANT_JOBS_QUOTAOVER  @"AJ - Quota Over"
#define APPLICANT_JOBS_VIEWJOBS  @"AJ - View Jobs"
#define APPLICANT_JOBS_VIEWDETAILS  @"AJ - View Detail"
#define APPLICANT_JOBS_CLICKURLS  @"AJ - Click URLs"
#define APPLICANT_JOBS_RIGHTSWIPE  @"AJ - R Swipe"
#define APPLICANT_JOBS_RIGHTPASS  @"AJ - R Pass"
#define APPLICANT_JOBS_LEFTSWIPE  @"AJ - L Swipe"
#define APPLICANT_JOBS_LEFTPASS  @"AJ - L Pass"

#define APPLICANT_ACTIVITY_LISTVIEW  @"AAI - List View"
#define APPLICANT_ACTIVITY_VIEWDETAIL   @"AAI - View Detail"
#define APPLICANT_ACTIVITY_CLICKURLS   @"AAI - Click URLs"
#define APPLICANT_ACTIVITY_CONVERSATION_LISTVIEW  @"AAC - List View"
#define APPLICANT_ACTIVITY_CONVERSATION_VIEWDETAIL   @"AAC - View Detail"
#define APPLICANT_ACTIVITY_CONVERSATION_CLICKURLS   @"AAC - Click URLS"
#define APPLICANT_ACTIVITY_CONVERSATION_CHATSCREEN  @"AAC - Chat Screen"

#define APPLICANT_PREFERENCE_VIEW @"APref - Pref View"
#define APPLICANT_PREFERENCE_UPDATE @"APref - Pref Update"
#define APPLICANT_SETTINGS_VIEW @"ASettings - Settings View"
#define APPLICANT_SETTINGS_UPDATE @"ASettings - Settings Update"
#define APPLICANT_PASSWORD_CHANGE @"APass - Password Change"


#define APPLICANT_ACCOUNT_VIEW @"AP - Account View"
#define APPLICANT_ACCOUNT_UPDATE @"AP - Account Update"


#define APPLICANT_UPLOAD_RESUME @"AP - Upload Resume"
#define APPLICANT_VIEW_RESUME @"AP - View Resume"
#define APPLICANT_EDIT_YOE @"AP - Edit YoE"
#define APPLICANT_JOB_FUNCTION @"AP - Job Function"
#define APPLICANT_ADD_EXPERIENCE @"AP - Add Experience"
#define APPLICANT_ADD_EDUCATION @"AP - Add Education"
#define APPLICANT_ADD_ACADEMIC @"AP - Add Academic"
#define APPLICANT_ADD_SKILLS @"AP - Add Skills"
#define APPLICANT_ADD_PHOTO @"AP - Add Photo"
#define APPLICANT_ADD_YOEOVERALL @"AP - Add YoE Overall"
#define APPLICANT_VIEW_PROFILE @"AP - View Profile"
#define APPLICANT_VIEW_INCOMPLETEPROFILE @"AP - View Incomplete Profile"
#define APPLICANT_PROFILE_UPDATE @"AP - Profile Update"

#define APPLICANT_SIGNUP_SCREEN @"AG - Sign up"
#define APPLICANT_USERLOGIN @"AG - Login"
#define APPLICANT_USERLOGOUT @"AG - Logout"
#define APPLICANT_FORGOT_PASSWORD @"AG - Forgot Password"

#define APPLICANT_HOME_INCOMPNOJOBS @"AH - Incom - No Jobs"
#define APPLICANT_HOME_INCOMPLETENOJOBS_TEXTCLICK @"AH - Incom - No Jobs - Click Text"
#define APPLICANT_HOME_INCOMPLETE_JOBSVIEW @"AH - Incom - Jobs - View"
#define APPLICANT_HOME_INCOMPLETEJOBS_DIALOG @"AH - Incom - Jobs - Dialog"
#define APPLICANT_HOME_INCOMPLETEJOBS_YESCLICK @"AH - Incom - Jobs - YES"
#define APPLICANT_HOME_INCOMPLETEJOBS_NOCLICK @"AH - Incom - Jobs - NO"

#define APPLICANT_MATCHSCREEN @"AM - Match Screen"
#define APPLICANT_STARTACONVERSATION @"AM - Start Conversation"


#define APPLICANT_INCOMPLETE_PROFILE_MISSINGEDUCATION @"APIn - Add Education"
#define APPLICANT_INCOMPLETE_PROFILE_MISSINGXPERINCE @"APIn - Add Experience"
#define APPLICANT_INCOMPLETE_PROFILE_MISSINGEDUANDEXP @"APIn - Add Edu Exp"



//COMPANY Side MixPanel Event Names

#define COMPANY_JOB_PREFERNCES  @"EP - Location Applicant"
#define COMPANY_JOB_PREFERNCES_SAVE  @"EP - Location Applicant Save"


#define COMPANY_PREFERENCE_VIEW  @"CPref - Pref View"
#define COMPANY_PREFERENCE_UPDATE    @"CPref - Pref Update"
#define COMPANY_SETTINGS_VIEW    @"CSettings - Settings View"
#define COMPANY_SETTINGS_UPDATE   @"CSettings - Settings Update"
#define COMPANY_PASSWORD_CHANGE    @"CPass - Password Change"

#define COMPANY_GENERAL_SIGNUP       @"CG - Sign up"
#define COMPANY_GENERAL_LOGIN      @"CG - Login"
#define COMPANY_GENERAL_LOGOUT     @"CG - Logout"
#define COMPANY_GENERAL_FORGOTPASSWORD      @"CG - Forgot Password"

#define COMPANY_MATCH_SCREEN @"CM - Match Screen"
#define COMPANY_STARTACONVERSATION @"CM - Start Conversation"




#define COMPANY_ACTIVITY_LISTVIEW @"CAI - List View"
#define COMPANY_ACTIVITY_DETAILVIEW @"CAI - View Detail"
#define COMPANY_ACTIVITY_URLCLICK @"CAI - Click URLs"

#define COMPANY_ACTIVITY_CONVERSATION_LISTVIEW @"CAC - List View"
#define COMPANY_ACTIVITY_CONVERSATION_VIEWDETAIL @"CAC - View Detail"
#define COMPANY_ACTIVITY_CONVERSATION_URLCLICKED @"CAC - Click URLS"
#define COMPANY_ACTIVITY_CONVERSATION_CHATSCREEN @"CAC - Chat Screen"





#define COMPANY_HOME_POSTJOBVIEW @"EH - Post Job View"
#define COMPANY_HOME_POSTJOBCLICK @"EH - Post Job Click"
#define COMPANY_HOME_JOBS_NOAPPLICANTS @"EH - Jobs - No Apps"
#define COMPANY_HOME_JOBS_NOAPPLICANTS_PREFCLICK @"EH - Jobs - No Apps - Click"


#define COMPANY_HOME_DAILYQUOTAOVER @"EH - Quota Over"

#define COMPANY_HOME_VIEWAPPLICANTS @"EH - View Applicants"
#define COMPANY_HOME_VIEWDETAIL @"EH - View Detail"
#define COMPANY_HOME_URLCLICK @"EH - Click URLs"
#define COMPANY_HOME_RIGHTSWIPE @"EH - R Swipe"
#define COMPANY_HOME_RIGHTPASS @"EH - R Pass"
#define COMPANY_HOME_LEFTSWIPE @"EH - L Swipe"
#define COMPANY_HOME_LEFTPASS @"EH- L Pass"




#define COMPANY_JOB_POST @"CJ - Post Job"
#define COMPANY_JOB_ACTIVE @"CJ - Active"
#define COMPANY_JOB_PENDING @"CJ - Pending"
#define COMPANY_JOB_CLOSED @"CJ - Closed"
#define COMPANY_JOB_ACTIVEDETAIL @"CJ - Active Detail"
#define COMPANY_JOB_PENDINGDETAIL @"CJ - Pending Detail"
#define COMPANY_JOB_CLOSEDDETAILS @"CJ - Closed Detail"
#define COMPANY_JOB_EDITACTIVE @"CJ - Edit Active"
#define COMPANY_JOB_EDITPENDING @"CJ - Edit Pending"



#define COMPANY_PROFILE_VIEW @"CP - View Profile"
#define COMPANY_PROFILE_EDIT @"CP - Edit Company Profile"
#define COMPANY_PROFILE_ADDPIC @"CP - Add Picture"

#define COMPANY_PROFILE_RECRUITERVIEW @"CP - View Recruiter Account"
#define COMPANY_PROFILE_EDITEMPLOYEACCOUNT @"CP - Edit Employer Account"

#define APPLICANTS_JOBS @"A iOS - Jobs"
#define APPLICANTS_ACTIVITY @"A iOS - Activity"
#define APPLICANTS_MORE @"A iOS - More"

#define COMPANY_APPLICANTS @"C iOS - Applcant"
#define COMPANY_ACTIVITY @"C iOS - Activity"
#define COMPANY_MORE_TAB @"C iOS - More"

#define COMPANY_SIGNUP_SCREEN @"CS - Signup"
#define COMPANY_VERIFYEMAIL_SCREEN @"CS - Verify Email"
#define COMPANY_CREATE_COMPANY @"CS - Create Company"
#define COMPANY_INDUSTRIES @"CS - Industries"
#define COMPANY_COMPANYFULL @"CS - Company Full"
#define COMPANY_HOME_SCREEN @"CS - Home (Success)"


//NSUSERDefaults Kye's
#define RECRUITER_REGISTRATION_ID @"recruiter_Registration_Id"
#define APPLICANT_REGISTRATION_ID @"applicant_Registration_Id"
#define SAVE_COMPANY_ID @"save_Company_Id"
#define PUSH_TOKEN_ID @"push_Token"
#define LAST_CREATED_JOB_ID @"last_Created_Job_Id"
#define LAST_CREATED_JOB_NAME @"last_Created_Job_Name"
#define SESSION_ID @"sessionId"
#define  PUBNUB @"FCM"
#define NOTIFICATION_TYPE @"notification_type"
#define ISLOGEDIN @"isLogedIn"
#define SUCESS_STRING @"sucess"
#define HTTPS_STRING @"http://"
#define FACEBOOK_URL @"facebook_url"
#define LINKEDIN_URL @"linkedin_url"
#define TWITTER_URL @"twitter_url"
#define COMPANY_DISCRIPTION_PLACE_HOLDER @"Enter your short description."
#define DEVICE_TYPE_STRING @"iOS"

//View Controller and Controller Identifiers
#define WRCREATE_CREATE_COMPANY_ACCOUNT_IDENTIFIER @"WRCreateComapnyAccountIdentifier"
#define WRCREATE_CREATE_COMPANY_ACCOUNT @"WRCreateComapnyAccount"
#define WRCHECK_YOUR_EMAIL_IDENTIFIER @"WRCheckYourEmailIdentifier"
#define WRCHECK_YOUR_EMAIL @"WRCheckYourEmail"
#define WRCREATE_COMPANY_PROFILE_IDENTIFIER @"WRCreateCompanyProfileIdentifier"
#define WRCREATE_COMPANY_PROFILE @"WRCreateCompanyProfile"
#define WRUPLOAD_A_PICTURE_IDENTIFIER @"WRUploadAPictureIdentifier"
#define WRUPLOAD_A_PICTURE @"WRUploadAPicture"
#define WRCHOOSE_COMPANY_INDUSTRY_IDENTIFIER @"WRChooseCompanyIndustryIdentifier"
#define WRCHOOSE_COMPANY_INDUSTRY @"WRChooseCompanyIndustry"
#define WRENTER_SOCIAL_MEDIA_IDENTIFIER @"WREnterSocialMediaIdentifier"
#define WRENTER_SOCIAL_MEDIA @"WREnterSocialMedia"
#define WREDIT_COMPANY_PROFILE_IDENTIFIER @"WREditCompanyProfileIdentifier"
#define WREDIT_COMPANY_PROFILE @"WREditCompanyProfile"
#define TABBAR_CONTROLLER_IDENTIFIER @"WRTabbarControllerIdentifier"
#define WRJOBS_VIEW_CONTROLLER @"WRJobsViewController"
#define WRJOBS_VIEW_CONTROLLER_IDENTIFIER @"WRJobsViewControllerIdentifier"
#define  WRACTIVITY_VIEW_CONTROLLER @"WRActivityViewController"
#define  WRACTIVITY_VIEW_CONTROLLER_IDENTIFIER @"WRActivityViewControllerIdentifier"
#define  WRPROFILE_VIEW_CONTROLLER @"WRProfileViewController"
#define  WRPROFILE_VIEW_CONTROLLER_IDENTIFIER @"WRProfileViewControllerIdentifier"
#define WRACCOUNTS_VIEWCONTROLLER_IDENTIFIER  @"WRAccountsViewControllerIdentifier"
#define WRACCOUNTS_VIEWCONTROLLER @"WRAccountsViewController"
#define WRCANDIDATE_PROFILE_CONTROLLER_IDENTIFIER @"WRCandidateProfileControllerIdentifier"
#define WRCANDIDATE_PROFILE_CONTROLLER @"WRCandidateProfileController"
#define  WRCREATE_NEW_JOB_CONTROLLER @"WRCreateNewJobController"
#define  WRCREATE_NEW_JOB_CONTROLLER_IDENTIFIER @"WRCreateNewJobControllerIdentifier"
#define JOBCARDVIEW @"JobsCardView"
#define APPLICANTCARDVIEW @"ApplicantCardView"
#define WRCARD_DETAILS_VIEW_CONTROLLER @"WRCardDetailsViewController"
#define WRCARD_DETAILS_VIEW_CONTROLLER_IDENTIFIER @"WRCardDetailsViewControllerIdentifier"
#define WRSETTINGS_VIEW_CONTROLLER_IDENTIFIER @"WRSettingsViewControllerIdentifier"
#define WRSETTINGS_VIEW_CONTROLLER @"WRSettingsViewController"
#define WRCHANGE_PASSWORD_CONTROLLER_IDENTIFIER @"WRChangePasswordControllerIdentifier"
#define GOODLUCK_CARD_VIEWCONTROLLER @"GoodLuckCardIdentifier"


#define WRVERIFY_MOBILE_VIEW_CONTROLLER_IDENTIFIER @"WRVerifyMobileControllerIdentifier"
#define WRVERIFY_MOBILE_VIEW_CONTROLLER @"WRVerifyMobileController"
#define WR_LOCATION_VIEW_CONTROLLER_IDENTIFIER @"WRLocationViewControllerIdentifier"
#define WR_LOCATION_VIEW_CONTROLLER @"WRLocationViewController"
#define WR_ADD_EXPERIANCE_CONTROLLER_IDENTIFIER @"WRAddExperianceControllerIdentifier"
#define WR_ADD_EXPERIANCE_CONTROLLER @"WRAddExperianceController"
#define WRSKILLS_VIEWCONTROLLER_IDENTIFIER @"WRSkillsViewControllerIdentifier"
#define WRSKILLS_VIEWCONTROLLER @"WRSkillsViewController"
#define WRAPPLICANT_EDIT_PROFILE_IDENTIFIER @"WRApplicantEditProfileIdentifier"
#define WRAPPLICANT_EDIT_PROFILE @"WRApplicantEditProfile"
#define WRLOGIN_VIEWCONTROLLER_IDENTIFIER @"WRLoginViewControllerIdentifier"
#define WRFORGOT_PASSWORD_CONTROLLER_IDENTIFIER @"WRForgotPasswordControllerIdentifier"
#define WRPREFERECES_CONTROLER_IDENTIFIER @"WRPreferencesControllerIdentifier"
#define WRPREFERECES_LIST_CONTROLER_IDENTIFIER @"WRPrefrenceListControllerIdentifier"
#define CUSTOM_PREFERENCES_CELL_IDNETIFIER @"CustomPreferencesCellIdentifier"
#define  WRJOB_CARD_DETAILS_VIEW_CONTROLLER @"WRJobCardDetailsViewControllerIdentifier"
#define WRCONVERSATION_VIEWCONTROLLER_IDENTIFIER @"WRConversationViewControllerIdentifier"
#define TUTORIAL_SCREEN_IDENTIFIER @"WRTutorialScreenViewControllerIdentifier"

//Custom cell
#define CREATE_COMPANY_CUSTOM_CELL @"CreateCompanyCustomCell"
#define CREATE_COMPANY_CUSTOM_CELL_IDENTIFIER @"CreateCompanyCustomCellIdentifier"
#define MULTIPLE_SELECTION_CELL_IDENTIFIER @"MultipleSelectionCellIdentifier"
#define MULTIPLE_SELECTION_CELL_JOB_IDENTIFIER @"MultipleJobFunctionSelectionCellIdentifier"
#define MULTIPLE_SELECTION_CELL @"MultipleSelectionCell"
#define MULTIPLE_SELECTION_JOB_CELL @"MultipleJobFunctionSelectionCell"
#define  PROFILE_PHOTO_CUSTOM_CELL_IDENTIFIER @"ProfilePhotoCustomCellIdentifier"
#define  PROFILE_PHOTO_CUSTOM_CELL @"ProfilePhotoCustomCell"
#define  CUSTOM_TEXT_VIEW_CELL_IDENTIFIER @"CustomTextViewCellIdentifier"
#define  CUSTOM_COMPANY_TEXT_VIEW_CELL_IDENTIFIER @"CustomTextViewCellIdentifier1"

#define  CUSTOM_TEXT_VIEW_CELL @"CustomTextViewCell"
#define  CUSTOM_COMPANY_TEXT_VIEW_CELL @"EditCompanyTextViewCell"


#define  CUSTOM_SALARY_SLIDER_CELL_IDENTIFIER @"CustomSalarySilderCellIentifier"
#define  CUSTOM_SALARY_SLIDER_CELL @"CustomSalarySilderCell"
#define CUSTOM_SWITCH_CELL_IDENTIFIER @"CustomSwitchCellIdentifier"
#define CUSTOM_SWITCH_CELL @"CustomSwitchCell"
#define CUSTOM_SKILLS_CELL_IDENTIFIER @"CustomSkillsCellIdentifier"
#define CUSTOM_SKILLS_CELL @"CustomSkillsCell"
#define JOBCARD_HEADER_CELL  @"JobCardHeaderCell"
#define CHAT_JOBCARD_HEADER_CELL  @"ChatDetailJobViewCell"
#define JOBCARD_CUSTOM_CELL  @"JobCardCustomCell"
#define JOBCARDTEXTVIEWCELL @"JobCardTextViewCell"
#define GETCURRENT_LOCATIONCELL_IDENTIFIER @"GetCurrentLocationCellIdentifier"

#define JOBCARDSKILLSCELL @"JobCardSkillsCell"
#define JOBCARDDETAILEXPCELL @"JobCardDetailExpCell"
#define JOBCARD_HEADER_CELL_IDENTIFIER  @"JobCardHeaderCellIdentifier"
#define CHAT_JOBCARD_HEADER_CELL_IDENTIFIER  @"chatDetailJobViewIdentifier"

#define JOBCARD_HEADER_CELL_NEW_IDENTIFIER @"JobCardHeaderCellNewIdentifier"
#define JOBCARD_CUSTOM_CELL_IDENTIFIER  @"JobCardCustomCellIdentifier"
#define JOBCARD_TEXTVIEW_CELL_IDENTIFIER @"JobCardTextViewCellIdentifier"
#define JOBCARD_SKILLS_CELL_IDENTIFIER @"JobCardSkillsCellIdentifier"
#define JOBCARD_DETAIL_EXPCELL_IDENTIFIER @"JobCardDetailExpCellIdentifier"
#define  WRCUSTOM_INTRESTED_CELL_IDENTIFIER @"CustomIntrestedCellIdentifier"
#define  WRCUSTOM_INTRESTED_CELL @"CustomIntrestedCell"
#define WRCUSTOM_CONVERSATION_CELL_IDENTIFIER @"CustomConversationsCellIdentifier"
#define WRCUSTOM_CONVERSATION_CELL @"CustomConversationsCell"
#define MULTILABLE_CUSTOM_CELL_IDENTIFIER @"MultiLableCustomCellIdentifier"
#define MULTILABLE_CUSTOM_CELL @"MultiLableCustomCell"
#define SETTINGS_CUSTOM_CELL_IDENTIFIER @"SettingCustomCellIdentifier"
#define SETTINGS_CUSTOM_CELL @"SettingCustomCell"
#define AUTO_SUGGESTION_CELL_IDENTIFIER  @"AutoSuggestionCellIdentifier"
#define AUTO_SUGGESTION_CELL  @"AutoSuggestionCell"

#define GET_LOCATION_CELL  @"GetLocationTableViewCell"

#define CUSTOM_SKILLS_VIEW_CELL_IDENTIFIER @"CustomSklillsViewCellIdentifier"
#define CUSTOM_SKILLS_VIEW_CELL @"CustomSklillsViewCell"
#define CUSTOM_PREFERENCES_CELL @"CustomPreferencesCell"
#define COMPANY_SIGNUP @"company_signup"
#define APPLICANT_SIGNUP @"applicant_signup"
#define COMPANY_LOGIN @"company_login"
#define APPLICANT_LOGIN @"applicant_login"
#define EDIT_APPLICANT @"edit_applicant"
#define EDIT_COMPANY @"edit_company"
#define APPLICANT_CARD @"applicant_card"
#define APPLICANT_CARD_DETAILS @"applicant_card_details"
#define JOB_CARD @"job_card"
#define JOB_CARD_DETAILS @"job_card_details"
#define COMPANY_APPLIED @"company_applied"
#define COMPANY_CONVERSATION @"company_conversation"
#define COMPANY_CHAT @"company_chat"
#define APPLICANT_APPLIED @"applicant_applied"
#define APPLICANT_CONVERSATION @"applicant_conversation"
#define APPLICANT_CHAT @"applicant_chat"
#define COMPANY_ACCOUNT @"company_account"
#define APPLICANT_ACCOUNT @"applicant_account"
#define COMPANY_PREFERENCES @"company_preferences"
#define APPLICANT_PREFERENCES @"applicant_preferences"
#define COMPANY_SETTINGS @"company_settings"
#define APPLICANT_SETTINGS @"applicant_settings"
#define COMPANY_MORE @"company_more"
#define APPLICANT_MORE @"applicant_more"
#define COMPANY_MATCH @"company_match"
#define APPLICANT_MATCH @"applicant_match"
#define CREATE_JOB @"create_job"
#define EDIT_JOB @"edit_job"
#define  JOB_CLOSED @"job_closed"

#define APPLICANT_LEFT_SWIPE @"applicant_left_swipe"
#define APPLICANT_RIGHT_SWIPE @"applicant_right_swipe"
#define COMPANY_LEFT_SWIPE @"company_left_swipe"
#define COMPANY_RIGHT_SWIPE @"company_right_swipe"
#define JOBS_LIST_SCREEN @"view_posted_jobs"
#define COMPANY_FULLPROFILE_DONE @"company_fullprofile_done"
#define  APPLICANT_FULLPROFILE_DONE @"applicant_fullprofile_done"


#endif /* Constrant_h */
