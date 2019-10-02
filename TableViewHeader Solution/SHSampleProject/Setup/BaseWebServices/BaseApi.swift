

//  Created by Shezad Ahamed on 17/08/19.
//  Copyright © 2019 Shezad Ahamed. All rights reserved.
//


import Foundation
import Alamofire
import ObjectMapper
import KSToastView

class BaseApi: NSObject {
    
    typealias RequestCompletion = (_ error: APIResultStatus?, _ data: AnyObject?) -> Void
    var completionBlock: RequestCompletion!
    var requestMethod: HTTPMethod!
    var requestUrl: String!
    var requestObj: Mappable?
    var isObjectMapper = true
    var showErrorMessage = true
    
    func processResponse(response:  Any?) -> BaseApiResponse{
        assert(false, "This method must be overriden by the subclass")
        let response: BaseApiResponse! = nil
        return response
    }
    
    func setupBaseUrl() {
         requestUrl = ApiPaths.baseUrl+requestUrl
    }
    
    func processResponseMappable(response: Any?) -> AnyObject{
        let response: AnyObject! = nil
        return response
    }
    
    func getHeader() -> Dictionary<String, String>?{
        
        var headers: HTTPHeaders = [:]
        
        headers["Accept"] = "application/json"
        headers["Content-Type"] = "application/json"
        if ACCESSTOKEN != ""{
            headers["user-token"] = ACCESSTOKEN
        }
        return headers
    }
    
    func getEncoding() -> ParameterEncoding{
        //Alamofire.ParameterEncoding =  JSONEncoding.default
        if requestMethod == .get {
            return URLEncoding.default
        }else if requestMethod == .post{
            return URLEncoding.default
        }
        
        return URLEncoding.default
    }
    
    
    func performApi(completion: @escaping RequestCompletion) -> Void{
        self.setupBaseUrl()
        self.completionBlock = completion
        
        let rechability = NetworkReachabilityManager()
        
        if rechability?.isReachable == false {
            self.showToast("No Network available!")
            self.completionBlock(APIResultStatus.networkIssue, nil)
            return
        }
        
        
        var params :[String:Any]? = [:]
        
        if requestObj != nil {
            params = (requestObj?.toJSON())!
        }
        else{
            params = nil
        }
    
        request(requestUrl, method: requestMethod, parameters: (params == nil ? nil : params!), encoding: getEncoding(), headers: getHeader()).responseJSON { (response: DataResponse<Any>) in

            
            if response.result.isSuccess  {
                guard let infoFromApiCall = response.result.value as? [String:Any] else{
                    
                    guard let apiCallResult = response.result.value as? [Any] else{
                        self.completionBlock(APIResultStatus.failure, nil)
                        return
                    }
                    
                    if self.isObjectMapper == false{
                        if response.data?.count != 0 {
                            let responseData = self.processResponseMappable(response: apiCallResult)
                            self.completionBlock(APIResultStatus.success, responseData as AnyObject)
                        }else{
                            self.showToast("Something went wrong!!")
                            self.completionBlock(APIResultStatus.failure, nil)
                        }
                        
                    }else{
                        let responseData = self.processResponse(response: apiCallResult)
                        self.completionBlock(APIResultStatus.success, responseData as AnyObject)
                    }
                    return
                }
                // if error occured
                if let status = infoFromApiCall["status"] as? Int{
                    if status == 3 || status == 4{
                        let appDelegate = UIApplication.shared.delegate as? AppDelegate
                        appDelegate?.didLogout()
                        self.cancelAPIRequests()
                        self.completionBlock(APIResultStatus.tokenIssue, nil)
                        return
                    }
                }
                
                //api call is sucess
                if self.isObjectMapper == false{
                    if response.data?.count != 0 {
                        let responseData = self.processResponseMappable(response: infoFromApiCall)
                        self.completionBlock(APIResultStatus.success, responseData as AnyObject)
                    }else{
                        self.showToast("Something went wrong!!")
                        self.completionBlock(APIResultStatus.failure, nil)
                    }
                    
                }else{
                    let responseData = self.processResponse(response: infoFromApiCall)
                    self.completionBlock(APIResultStatus.success, responseData as AnyObject)
                }
                
            }else{
                 self.completionBlock(APIResultStatus.failure, nil)
            }
            
        }
        
    }
    
    func requestNew(completion: @escaping RequestCompletion) -> Void{
        
        self.setupBaseUrl()
        self.completionBlock = completion
        
        let rechability = NetworkReachabilityManager()
        
        if rechability?.isReachable == false {
            self.showToast("No Network available!")
            self.completionBlock(APIResultStatus.networkIssue, nil)
            return
        }
        
        
        var params :[String:Any] = [:]
        
        if requestObj != nil {
            params = (requestObj?.toJSON())!
        }
        var headers: HTTPHeaders = [:]
        headers["Content-Type"] = "application/x-www-form-urlencoded"
        headers["user-token"] = ACCESSTOKEN
        headers["Accept"] = "application/json"
        request(requestUrl, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON {
            response in
            
        }
        
        
    }
    
    func showToast(_ message:String?){
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
            KSToastView.ks_showToast(message ?? "")
        }
    }
    
    
    //To cancel All api calls
    func cancelAPIRequests(){
        defaultManager.session.getAllTasks{ (task) in
            task.forEach{$0.cancel()}
        }
    }
    
    //To cancel specific api calls. Should specify a part of url
    func cancelAPICallsContaining(string:String,completion:(()->Void)? = nil){
        
        defaultManager.session.getAllTasks
            { (task) in
                task.forEach{
                    if ($0.originalRequest?.url?.absoluteString.contains(string) == true){
                        $0.cancel()
                    }
                }
                DispatchQueue.main.async {
                    completion?()
                }
        }
    }
    
    func multipartRequest(imagesToBeUploded: [UIImage]?,pdfToBeUploded: Data?, fileName:String, completion: @escaping RequestCompletion) -> Void{
        
        self.requestUrl = ApiPaths.baseImagePath
        self.completionBlock = completion
        
        let rechability = NetworkReachabilityManager()
        
        if rechability?.isReachable == false {
            self.showToast("No Network available!")
            self.completionBlock(APIResultStatus.networkIssue, nil)
            return
        }
        
        if showLoading{
            E3ProgressHUD.shared.showClassicLoading()
        }
        
        var params :[String:Any] = [:]
        
        if requestObj != nil {
            params = (requestObj?.toJSON())!
        }
        
        
        var headers : [String:String] = ["Content-Type" : "multipart/form-data"]
        
        let base64String = "admin:wpT0 f9YF Jb38 rb7v Tlfc kHBv".data(using: .utf8, allowLossyConversion: false)?.base64EncodedString()
        
        
        headers["Authorization"] = "Basic \(base64String ?? "")"
    
        
        print("############### Api Call ##################")
        print("Req Url",requestUrl)
        print("Params", params)
        print("Req Method", requestMethod)
        print("Headers", headers)
        print("*******************************************")
        
        Alamofire.upload(multipartFormData:{ multipartFormData in
            if let image = imagesToBeUploded{
                var index = 1
                if image.count == 1{
                    if let currentImageData = image[0].resize(targetSize: CGSize(width: 360, height: 360)).jpegData(compressionQuality: 0.7){
                        multipartFormData.append(currentImageData, withName: "file", fileName: "file.jpg", mimeType: "image/jpeg")
                    }
                }else{
                    image.forEach({ (currentImage) in
                        if let currentImageData = currentImage.resize(targetSize: CGSize(width: 360, height: 360)).jpegData(compressionQuality: 0.7){
                            multipartFormData.append(currentImageData, withName: "file", fileName: "file"+"\(index)"+".jpg", mimeType: "image/jpeg")
                            index += 1
                        }
                    })
                }
            }
            
            if let pdfData = pdfToBeUploded{
                  multipartFormData.append(pdfData, withName: "file", fileName: fileName, mimeType:"application/pdf")
            }
            
            for (key, value) in params{
                if let value = value as? String{
                    multipartFormData.append((value.data(using: .utf8))!, withName: key)
                }
        
                
            }}, to: requestUrl, method: .post, headers: headers,
                encodingCompletion: { encodingResult in
                    
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.responseJSON{
                            response in
                            if self.showLoading{
                                E3ProgressHUD.shared.dismiss()
                            }
                            print("############### Api Call Response ##################")
                            print("Result:", response.result.value as Any)
                            print("Status code", response.response?.statusCode)
                            print("*******************************************")
                            switch response.result{
                            case .success(let JSON):
                                if let infoFromApiCall = JSON as? Dictionary<String, Any>{
                                    if self.isObjectMapper == false{
                                        // if error occured
                                        if let status = infoFromApiCall["status"] as? Int{
                                           if status == 3 || status == 4{
                                                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                                                    appDelegate?.didLogout()
                                                    self.cancelAPIRequests()
                                                    self.completionBlock(APIResultStatus.tokenIssue, nil)
                                               return
                                                }
                                         
                                        }
                                        if response.data?.count != 0 {
                                            let responseData = self.processResponseMappable(response: infoFromApiCall)
                                            self.completionBlock(APIResultStatus.success, responseData as AnyObject)
                                        }else{
                                            self.showToast("Something went wrong!!")
                                            self.completionBlock(APIResultStatus.failure, nil)
                                        }
                                        
                                    }else{
                                        let responseData = self.processResponse(response: infoFromApiCall)
                                        self.completionBlock(APIResultStatus.success, responseData as AnyObject)
                                    }
                                }
                            case .failure:
                                self.completionBlock(APIResultStatus.failure,nil)
                            }
                        }
                        upload .responseString(completionHandler:{ (result) in
                        })
                        
                    case .failure:
                        self.completionBlock(APIResultStatus.failure,nil)
                    }
        })
        
    }
    
    // parameter type Array
    func requestJsonArray(completion: @escaping RequestCompletion) -> Void{
        self.setupBaseUrl()
        self.completionBlock = completion
        let request = NSMutableURLRequest(url: URL(string: requestUrl)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        //        if userdefaultsModel.accessToken != ""{
        //            request.setValue(userdefaultsModel.accessToken, forHTTPHeaderField: "sec_key")
        //        }
        var params :[String:Any] = [:]
        
        if requestObj != nil {
            params = (requestObj?.toJSON())!
        }
        request.httpBody = try! JSONSerialization.data(withJSONObject: params, options: [])
        request.timeoutInterval = 40
        let convertibleRequest = MLURLRequestConvertible()
        
        convertibleRequest.request = request as URLRequest
        
        Alamofire.request(convertibleRequest).responseJSON
            { response in
                
                switch response.result
                {
                case .success(let JSON):
                    
                    guard let infoFromApiCall = JSON as? [String:Any] else{
                        return
                    }
                    if let success = infoFromApiCall["success"] as? [String:Any]{
                        if  let status = success["success"] as? String,status == "False"{
                            self.showToast(success["message"] as? String)
                        }
                        if let message = success["message"] as? String, message == "Authentication Failed"{
                            let appDelegate = UIApplication.shared.delegate as? AppDelegate
                            appDelegate?.didLogout()
                        }
                    }
                    
                    if self.isObjectMapper == false{
                        if response.data?.count != 0 {
                            let responseData = self.processResponseMappable(response: infoFromApiCall)
                            self.completionBlock(APIResultStatus.success, responseData as AnyObject)
                        }else{
                            self.showToast("Something went wrong!!")
                            self.completionBlock(APIResultStatus.failure, nil)
                        }
                        
                    }else{
                        let responseData = self.processResponse(response: infoFromApiCall)
                        self.completionBlock(APIResultStatus.success, responseData as AnyObject)
                    }
                    
                case .failure(let error):
                    
                    self.showToast("Server not responding. Please try later")
                }
        }
    }
    
    let defaultManager: Alamofire.SessionManager = {
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "" : .disableEvaluation
            //            BASE_URL_P: .disableEvaluation
        ]
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = 120 // seconds
        configuration.timeoutIntervalForResource = 120
        
        return Alamofire.SessionManager(
            configuration: configuration,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
    }()
    
    
    
    
}

class MLURLRequestConvertible : URLRequestConvertible{
    
    var request : URLRequest?
    func asURLRequest() throws -> URLRequest{
        
        return request!
    }
}

enum APIResultStatus{
    case success
    case failure
    case tokenIssue
    case networkIssue
}

class API: BaseApi{
    func api(object: RegisterRequest, completion: @escaping RequestCompletion){
        requestUrl = ApiPaths.baseUrl
        requestMethod = .post
        requestObj = object
        isObjectMapper = false
        super.performApi(completion: completion)
    }
    override func processResponseMappable(response: Any?) -> AnyObject {
        let responseDetails = Mapper<SWRegisterResponse>().map(JSONObject: response)
        return responseDetails!
    }
}

class Request: Mappable {
 
    var firstName: String?

    required init?(map: Map) {
        
    }
    
    init() {
        
    }
    
    func mapping(map: Map) {
        firstName <- map["fname"]
    }
    
}

class Response : BaseApiResponse{
    
    var message : String?
    var status : Int?
    
    override func mapping(map: Map)
    {
        message <- map["message"]
        status <- map["status"]
        
    }
    
}
//
//pod 'Alamofire', '4.7.3'
//pod 'AlamofireObjectMapper', '5.1.0'
