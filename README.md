iOS_Class_Hierarchy
===================

用 Ruby 写的脚本，可以提取 iOS 项目中的类继承关系。

用法：

	ruby class_hierarchy.rb path_to_iOS_project
	
抽取出的类关系会在 Ruby 脚本的当前执行目录下生成 Extracted 文件夹，里面是 JSON 格式的结果文件。 对 AFNetworking [提取的类关系](./Extracted)：

	{
	  "NSObject": [
	    "AFHTTPRequestOperationManager",
	    "AFNetworkReachabilityManager",
	    "AFSecurityPolicy",
	    {
	      "AFHTTPRequestSerializer": [
	        "AFJSONRequestSerializer",
	        "AFPropertyListRequestSerializer"
	      ]
	    },
	    "AFQueryStringPair",
	    "AFStreamingMultipartFormData",
	    "AFHTTPBodyPart",
	    {
	      "AFHTTPResponseSerializer": [
	        "AFJSONResponseSerializer",
	        "AFXMLParserResponseSerializer",
	        "AFXMLDocumentResponseSerializer",
	        "AFPropertyListResponseSerializer",
	        "AFImageResponseSerializer",
	        "AFCompoundResponseSerializer"
	      ]
	    },
	    {
	      "AFURLSessionManager": [
	        {
	          "AFHTTPSessionManager": [
	            "AFAppDotNetAPIClient"
	          ]
	        }
	      ]
	    },
	    "AFURLSessionManagerTaskDelegate",
	    "AppDelegate",
	    "Post",
	    "User",
	    "AFNetworkingTests",
	    "AFNetworkActivityIndicatorManager"
	  ]
	}