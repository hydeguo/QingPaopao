

import Foundation
import Moya



enum MyAPI {
    case login(phone: String, password: String)
    case logout
    case thirdLogin(key: String,type: String)
    case register(phone: String,userName: String, password: String,v_code:String)
    case thirdRegister(userName: String, key: String,type:String)
    case thirdBinding(key: String,type:String)
    case getThirdBinding()
    case changePassword(userId: String, password: String,v_code:String)
    case getCode(phone: String)
    case checkPhone(phone: String,v_code:String)
    case changePhone( phone: String,v_code:String)
    case changeUserName(userName: String)
    case changeIcon(icon: String)
    case addOrUpdateACup(type:String,uuid:String,name: String,add:Bool)
    case deleteACup(uuid:String)
    case cupList
    case addOrUpdateAddress(addressId:String,userName:String,address1: String,address2: String,tel:Int,isDefault: Bool)
    case setDefaultAddress(addressId:String)
    case payMentExchange(addressId:String,title:String,image:String,goodsId:Int,num: Int,offerPrice:Int,singlePrice:Int)
    case payMentScores(addressId:String,title:String,image:String,goodsId:Int,num: Int,singlePrice:Int)
    case payMentCrowdfunding(addressId:String,title:String,image:String,goodsId:Int,num: Int,singlePrice:Int)
    case getExchangeOrder
    case getExchangeGoods
    case getScoresOrder
    case getCrowdfundingOrder
    case updateBodyProfiles(key:[String] ,value:[Double?])
    case drink(target:Int)
    case attendance
    case getTodayDrinkList
    case getDrinkList
    case getUserData
    case exchangeOrderUpdate(orderId:String,expressId:String)
    case orderStatusUpdate(orderId:String,status:Int)
    case crowdfundingOrderTotalMoney(goodsId:Int)
    case crowdfundingOrderTotalPeople(goodsId:Int)
    case addGeolocationParameters(device_id: String, time: String, lat: Double, long: Double, link: String)
    case getBlogPost(id:Int)
    case getBlogPostList(page:Int,num:Int)
    case getBlogPostComments(id:Int)
    case collectBlogPost(id:Int)
    case unCollectBlogPost(id:Int)
    case likeBlogPost(id:Int)
    case unLikeBlogPost(id:Int)
    case likeBlogComment(id:Int)
    case unLikeBlogComment(id:Int)
    case newComment(postId:Int,content:String,parent:Int)
    case newPost(title:String,content:String)
}


extension MyAPI: TargetType {
    var task: Task {
        switch self {
        case .login(let phone, let password):
            return .requestParameters(parameters: ["phone" : phone, "userPwd" : password.MD5], encoding: URLEncoding.default)
        case .thirdLogin(let key, let type):
            return .requestParameters(parameters: ["key" : key, "type" : type], encoding: URLEncoding.default)
        case .register(let phone, let userName,let password, let v_code):
            return .requestParameters(parameters: ["phone" : phone, "userName" : userName, "userPwd" : password.MD5,"v_code":v_code], encoding: URLEncoding.default)
        case .thirdRegister( let userName,let key, let type):
            return .requestParameters(parameters: [ "userName" : userName, "key" : key,"type":type], encoding: URLEncoding.default)
        case .thirdBinding( let key, let type):
            return .requestParameters(parameters: [  "key" : key,"type":type], encoding: URLEncoding.default)
        case .changePassword(let userId, let password, let v_code):
            return .requestParameters(parameters: ["phone" : userId, "userPwd" : password.MD5,"v_code":v_code], encoding: URLEncoding.default)
        case .getCode(let phone):
             return .requestParameters(parameters: ["phone" : phone], encoding: URLEncoding.default)
        case .checkPhone(let phone, let v_code):
            return .requestParameters(parameters: [ "phone" : phone, "v_code" : v_code], encoding: URLEncoding.default)
        case .changePhone( let phone, let v_code):
            return .requestParameters(parameters: [ "phone" : phone,"v_code":v_code], encoding: URLEncoding.default)
        case .changeUserName(let userName):
            return .requestParameters(parameters: [ "userName" : userName], encoding: URLEncoding.default)
        case .changeIcon(let icon):
            return .requestParameters(parameters: [ "icon" : icon], encoding: URLEncoding.default)
        case .addOrUpdateACup(let type, let uuid, let name,let add):
            return .requestParameters(parameters: [ "type" : type, "uuid" : uuid, "name" : name, "add" : add], encoding: URLEncoding.default)
        case .deleteACup(let uuid):
            return .requestParameters(parameters: [  "uuid" : uuid], encoding: URLEncoding.default)
        case .addOrUpdateAddress(let addressId, let userName, let address1, let address2,let tel, let isDefault):
            return .requestParameters(parameters: [ "addressId" : addressId, "userName" : userName, "address1" : address1,"address2" : address2, "tel" : tel, "isDefault" : isDefault], encoding: URLEncoding.default)
        case .setDefaultAddress(let addressId):
            return .requestParameters(parameters: [ "addressId" : addressId], encoding: URLEncoding.default)
        case .payMentExchange(let addressId,let title,let image,let goodsId,let num,let offerPrice,let singlePrice):
            return .requestParameters(parameters: [ "addressId" : addressId,"title":title,"image":image, "goodsId" : goodsId, "num" : num,"offerPrice" : offerPrice,"singlePrice" : singlePrice], encoding: URLEncoding.default)
        case .getExchangeOrder,.getExchangeGoods,.getScoresOrder,.getCrowdfundingOrder:
            return .requestParameters(parameters:[:], encoding: URLEncoding.default)
        case .updateBodyProfiles(let key, let value):
            var p:[String: Any] = [ "key1" : key[0], "value1" : value[0]! ]
            if(key[1].count>0){
                p["key2"] = key[1]
                p["value2"] = value[1]
            }
            if(key[2].count>0){
                p["key3"] = key[2]
                p["value3"] = value[2]
            }
            return .requestParameters(parameters: p, encoding: URLEncoding.default)
        case .drink(let target):
            return .requestParameters(parameters: ["target" : target], encoding: URLEncoding.default)
        case .exchangeOrderUpdate(let orderId , let expressId):
            return .requestParameters(parameters: ["orderId" : orderId,"expressId" : expressId], encoding: URLEncoding.default)
        case .orderStatusUpdate(let orderId , let status):
            return .requestParameters(parameters: ["orderId" : orderId,"status" : status], encoding: URLEncoding.default)
        case .addGeolocationParameters(let device_id, let time, let lat, let long, let link):
            return .requestParameters(parameters: ["device_id" : device_id, "time" : time, "lat" : lat, "long" : long, "link" : link ], encoding: URLEncoding.default)
        case .payMentScores(let addressId,let title,let image,let goodsId,let num,let singlePrice):
            return .requestParameters(parameters: [ "addressId" : addressId,"title":title,"image":image, "goodsId" : goodsId, "num" : num,"singlePrice" : singlePrice], encoding: URLEncoding.default)
        case .payMentCrowdfunding(let addressId,let title,let image,let goodsId,let num,let singlePrice):
            return .requestParameters(parameters: [ "addressId" : addressId,"title":title,"image":image, "goodsId" : goodsId, "num" : num,"singlePrice" : singlePrice], encoding: URLEncoding.default)
        case .crowdfundingOrderTotalMoney(let goodsId):
            return .requestParameters(parameters: [ "goodsId" : goodsId], encoding: URLEncoding.default)
        case .crowdfundingOrderTotalPeople(let goodsId):
            return .requestParameters(parameters: [ "goodsId" : goodsId], encoding: URLEncoding.default)
        case .getBlogPostList(let page,let num):
            return .requestParameters(parameters: [ "page" : page,"num" : num], encoding: URLEncoding.default)
        case .collectBlogPost(let id):
            return .requestParameters(parameters: [ "postId" : id], encoding: URLEncoding.default)
        case .unCollectBlogPost(let id):
            return .requestParameters(parameters: [ "postId" : id], encoding: URLEncoding.default)
        case .likeBlogPost(let id):
            return .requestParameters(parameters: [ "postId" : id], encoding: URLEncoding.default)
        case .unLikeBlogPost(let id):
            return .requestParameters(parameters: [ "postId" : id], encoding: URLEncoding.default)
        case .likeBlogComment(let id):
            return .requestParameters(parameters: [ "id" : id], encoding: URLEncoding.default)
        case .unLikeBlogComment(let id):
            return .requestParameters(parameters: [ "id" : id], encoding: URLEncoding.default)
        case .newPost(let title,let content):
            return .requestParameters(parameters: [ "title" : title,"content" : content], encoding: URLEncoding.default)
        case .newComment(let postId,let content,let parent):
            return .requestParameters(parameters: [ "postId" : postId,"content" : content,"parent" : parent], encoding: URLEncoding.default)
        default:
            return .requestPlain
        }
    }
    
    
    var headers: [String : String]? {
        return nil
    }
    
    var parameterEncoding: ParameterEncoding { return URLEncoding.default }
//    public var baseURL: URL { return URL(string:  "http://127.0.0.1:8081")! } //
    public var baseURL: URL { return URL(string:  server_url)! }
    
    public var path: String {
        switch self {
        case .login:
            return "/users/login"
        case .logout:
            return "/users/logout"
        case .thirdLogin:
            return "/users/thirdLogin"
        case .register:
            return "/users/register"
        case .thirdRegister:
            return "/users/thirdRegister"
        case .thirdBinding:
            return "/users/thirdBinding"
        case .getThirdBinding:
            return "/users/getThirdBinding"
        case .changePassword:
            return "/users/changePassword"
        case .getCode:
            return "/users/sendVerifyCode"
        case .checkPhone:
            return "/users/checkPhone"
        case .changePhone:
            return "/users/changePhone"
        case .changeUserName:
            return "/users/changeUserName"
        case .addOrUpdateACup:
            return "/users/addOrUpdateACup"
        case .deleteACup:
            return "/users/deleteACup"
        case .cupList:
            return "/users/cupList"
        case .addOrUpdateAddress:
            return "/users/addOrUpdateAddress"
        case .setDefaultAddress:
            return "/users/setDefaultAddress"
        case .getExchangeOrder:
            return "/goods/exchangeOrderList"
        case .getExchangeGoods:
            return "/goods/exchangeList"
        case .updateBodyProfiles:
            return "/users/updateBodyProfiles"
        case .changeIcon:
            return "/users/changeIcon"
        case .drink:
            return "/users/drink"
        case .getTodayDrinkList:
            return "/users/getTodayDrinkList"
        case .getDrinkList:
            return "/users/getDrinkList"
        case .payMentExchange:
            return "/goods/payMentExchange"
        case .exchangeOrderUpdate:
            return "/goods/exchangeOrderUpdate"
        case .orderStatusUpdate:
            return "/goods/orderStatusUpdate"
        case .addGeolocationParameters:
            return "/location"
        case .attendance:
            return "/users/attendance"
        case .payMentScores:
            return "/goods/payMentScores"
        case .payMentCrowdfunding:
            return "/goods/payMentCrowdfunding"
        case .getScoresOrder:
            return "/goods/scoresOrderList"
        case .getCrowdfundingOrder:
            return "/goods/crowdfundingOrderList"
        case .getUserData:
            return "/users/getUserData"
        case .crowdfundingOrderTotalMoney:
            return "/goods/crowdfundingOrderTotalMoney"
        case .crowdfundingOrderTotalPeople:
            return "/goods/crowdfundingOrderTotalPeople"
        case .getBlogPost(let id):
            return "/blog/post/\(id)"
        case .getBlogPostList:
            return "/blog/posts"
        case .getBlogPostComments(let id):
            return "/blog/postComments/\(id)"
        case .collectBlogPost:
            return "/blog/collect"
        case .unCollectBlogPost:
            return "/blog/unCollect"
        case .likeBlogPost:
            return "/blog/like"
        case .unLikeBlogPost:
            return "/blog/unLike"
        case .likeBlogComment:
            return "/blog/likeComment"
        case .unLikeBlogComment:
            return "/blog/unLikeComment"
        case .newComment:
            return "/blog/newComment"
        case .newPost:
            return "/blog/newPost"
            
        }
    }
    
    var method: Moya.Method {
        switch self {
            case  .getExchangeOrder ,
                  .getExchangeGoods,
                  .getScoresOrder,
                  .getCrowdfundingOrder,
                  .cupList,
                  .getUserData,
                  .getBlogPost,
                  .getBlogPostComments,
                  .getBlogPostList:
            return .get
    
            default:
            return .post
        }
    }
    var parameters: [String: Any]? {
        switch self {
            case .login(let userId, let password):
                    return ["userId" : userId, "userPwd" : password]
        default:
            return [:]
        }
        
    }
    
    public var validate: Bool {
        return true
    }
    public var sampleData: Data {
        return "[{\"name\": \"Repo Name\"}]".data(using: String.Encoding.utf8)!
    }
}
