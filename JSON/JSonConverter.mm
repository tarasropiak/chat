// CA7.cpp : Defines the entry point for the console application.
//

#include "JSonConverter.h"



using namespace std;


namespace JSonConverter
{
	void serialize(
		vector<string> recievers, 
		string& data_str, 
		int curentTime,
		int type,
		string& json_str 
		)
	{
		// Define Local variables
		Json::Value root;
		//Write "targets" to message
		for (unsigned i =0; i< recievers.size();i++)
			root["recievers"].append(recievers.at(i));
		
		//Write time to message
		root["time"]=curentTime;
		root["data"]=data_str;
		root["type"]=type;

		//Convert to result string;
		Json::FastWriter writer;
		json_str=writer.write(root);
	
    
    }
	void deserialize(
		int& currentTime,
		string& json_str,
		vector<string>& recievers,
		string& data_srt,
		int& type
		)
	{
		Json::Value root;
		Json::Reader reader;
		Json::Value jarray;

		if(reader.parse(json_str,root,false))
		{
		//Getting recievers from JSON
			jarray=root["recievers"];

			for (unsigned i=0;i<jarray.size();i++)
			{
				recievers.push_back(jarray[i].asString());
				cout<<jarray[i].asString();
			}

		//Get time from JSON
			currentTime=root["time"].asUInt();

		//Get message type from JSON
		    
			type=root["type"].asUInt();
			data_srt=root["data"].asString();
		}
		

	
	}
}


//int _tmain(int argc, _TCHAR* argv[])
//{
//	vector<string> _recievers;
//	string jsonmsg;
//	for (int i =0;i<8;i++)
//		_recievers.push_back(to_string(i));
//	string msg="1224323487";
//
//	int dTime=0;
//	vector<string> dRecievers;
//	string result;
//	int dtype=0;
//
//	 JsonMenager::serialize(dRecievers,msg,559,1,jsonmsg);
//	 JsonMenager::deserialize(dTime,jsonmsg,dRecievers,result,dtype);
//
//	  cout<<endl<<result;
//	  cout<<endl<<(unsigned)dTime;
//	system("pause");
//	return 0;
//
//
//
//

