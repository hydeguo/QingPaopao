//
//  UserAgreementVC.swift
//  Mywopin
//
//  Created by Hydeguo on 2018/6/17.
//  Copyright © 2018 Hydeguo. All rights reserved.
//

import Foundation



class UserAgreementVC: UIViewController {
    
    
    @IBOutlet var webView:UIWebView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.loadHTMLString(user_agreement, baseURL: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func back(_ sender: UIBarButtonItem) {
                self.dismiss(animated: true, completion: nil)
    }
    
    let user_agreement = """

<div class="mui-content popo-content bar-top">
<div class="mui-scroll-wrapper">
<div style="margin-top: 20px;padding-left: 20px;padding-right: 20px;">
<div>
<h5 style="font-weight: bolder;font-size: 16px;color: #323232;padding-top: 10px; padding-bottom: 10px;">特别提示</h5>
<p style="color: #323232; font-size: 15px;line-height: 1.8;">
在此特别提醒您（用户）在注册成为氢泡泡用户之前，请认真阅读本《氢泡泡用户服务协议》（以下简称“协议”）。确保您充分理解本协议中各条款。请您审慎阅读并选择接受或不接受本协议。除非您接受本协议所有条款，否则您无权注册、登录或使用本协议所涉服务。您的注册、登录、使用等行为将视为对本协议的接受，并同意接受本协议各项条款的约束。
本协议约定氢泡泡与用户之间关于“氢泡泡”服务（以下简称“服务”）的权利义务。“用户”是指注册、登录、使用本服务的个人。本协议可由氢泡泡随时更新，更新后的协议条款一旦公布即代替原来的协议条款，恕不再另行通知，用户可在本APP中查阅最新版协议条款。在修改协议条款后，如果用户不接受修改后的条款，请立即停止使用氢泡泡提供的服务，用户继续使用氢泡泡提供的服务将被视为接受修改后的协议。
</p>
</div>

<div>
<h5 style="font-weight: bolder;font-size: 18px;color: #323232;padding-top: 10px;padding-bottom: 10px;">一、帐号注册</h5>
<p style="color: #323232;font-size: 15px;line-height: 1.8;">
1、用户在使用本服务前需要注册一个“氢泡泡”账号。“氢泡泡”账号应当使用手机号码绑定注册，请用户使用尚未与“氢泡泡”账号绑定的手机号码，以及未被氢泡泡根据本协议封禁的手机号码注册“氢泡泡”账号，也可以绑定第三方账户。氢泡泡可以根据用户需求或产品需要对账号注册和绑定的方式进行变更，而无须事先通知用户。
</p>
<p style="color: #323232;font-size: 15px;line-height: 1.8;">
2、如果注册申请者有被氢泡泡封禁的先例或涉嫌虚假注册及滥用他人名义注册，及其他不能得到许可的理由，氢泡泡将拒绝其注册申请。
</p>
<p style="color: #323232;font-size: 15px;line-height: 1.8;">
3、鉴于“氢泡泡”账号的绑定注册方式，您同意氢泡泡在注册时将允许您的手机号码及手机设备识别码等信息用于注册。
</p>
<p style="color: #323232;font-size: 15px;line-height: 1.8;">
4、在用户注册及使用本服务时，氢泡泡需要搜集能识别用户身份的个人信息以便氢泡泡可以在必要时联系用户，或为用户提供更好的使用体验。氢泡泡搜集的信息包括但不限于用户的姓名、地址；氢泡泡同意对这些信息的使用将受限于第三条用户个人隐私信息保护的约束。
</p>
</div>

<div>
<h5 style="font-weight: bolder;font-size: 18px;color: #323232;padding-top: 10px;padding-bottom: 10px;">二、账户安全</h5>
<p style="color: #323232;font-size: 15px;line-height: 1.8;">

1、用户一旦注册成功，成为氢泡泡的用户，将得到一个用户名和密码，并有权利使用自己的用户名及密码随时登陆氢泡泡。
</p>
<p style="color: #323232;font-size: 15px;line-height: 1.8;">
2、用户对用户名和密码的安全负全部责任，同时对以其用户名进行的所有活动和事件负全责。
</p>
<p style="color: #323232;font-size: 15px;line-height: 1.8;">
3、用户不得以任何形式擅自转让或授权他人使用自己的氢泡泡用户名。
</p>
<p style="color: #323232;font-size: 15px;line-height: 1.8;">
4、如果用户泄漏了密码，有可能导致不利的法律后果，因此不管任何原因导致用户的密码安全受到威胁，应该立即和氢泡泡客服人员取得联系，否则后果自负。
</p>
<!--<p style="color: #323232;font-size: 15px;line-height: 1.8;">
5．用户同意蜗品商城可在以下事项中使用用户的个人隐私信息：<br />
(1) 蜗品商城向用户及时发送重要通知，如软件更新、本协议条款的变更等事项；
<br />
(2) 蜗品商城内部进行审计、数据分析和研究等，以改进蜗品商城的产品、服务和与用户之间的沟通；
<br />
(3) 依本协议约定，蜗品商城管理、审查用户信息及进行处理措施；
<br />
(4) 适用法律法规规定的其他事项。
<br />
除上述事项外，如未取得用户事先同意，蜗品商城不会将用户个人隐私信息使用于任何其他用途。
</p>-->
<!--<p style="color: #323232;font-size: 15px;line-height: 1.8;">
6．为了改善蜗品商城的技术和服务，向用户提供更好的服务体验，蜗品商城或可会自行收集使用或向第三方提供用户的非个人隐私信息。
</p>-->
</div>

<div>
<h5 style="font-weight: bolder;font-size: 18px;color: #323232;padding-top: 10px;padding-bottom: 10px;">三、用户声明与保证</h5>
<p style="color: #323232;font-size: 15px;line-height: 1.8;">
1、用户承诺其为具有完全民事行为能力的民事主体，且具有达成交易履行其义务的能力。
</p>
<p style="color: #323232;font-size: 15px;line-height: 1.8;">
2、用户有义务在注册时提供自己的真实资料，并保证诸如手机号码、姓名、所在地区等内容的有效性及安全性，保证氢泡泡工作人员可以通过上述联系方式与用户取得联系。同时，用户也有义务在相关资料实际变更时及时更新有关注册资料。
</p>
<p style="color: #323232;font-size: 15px;line-height: 1.8;">
3、用户通过使用
氢泡泡的过程中所制作、上载、复制、发布、传播的任何内容，包括但不限于账号头像、名称、用户说明等注册信息及认证资料，或文字、语音、图片、视频、图文等发送、回复和相关链接页面，以及其他使用账号或本服务所产生的内容，不得违反国家相关法律制度，包含但不限于如下原则：
<br />
(1) 反对宪法所确定的基本原则的；
<br />
(2) 危害国家安全，泄露国家秘密，颠覆国家政权，破坏国家统一的；
<br />
(3) 损害国家荣誉和利益的；
<br />
(4) 煽动民族仇恨、民族歧视，破坏民族团结的；
<br />
(5) 破坏国家宗教政策，宣扬邪教和封建迷信的；
<br />
(6) 散布谣言，扰乱社会秩序，破坏社会稳定的。
<br />
(7)  散布淫秽、色情、赌博、暴力、凶杀、恐怖或者教唆犯罪的；
<br />
(8)  侮辱或者诽谤他人，侵害他人合法权益的；
<br />
(9)  含有法律、行政法规禁止的其他内容的。
</p>
<p style="color: #323232;font-size: 15px;line-height: 1.8;">
4、用户不得利用“氢泡泡”账号或本服务制作、下载、复制、发布、传播下干扰“氢泡泡”正常运营，以及侵犯其他用户或第三方合法权益的内容：
<br />
(1) 含有任何性或性暗示的；
<br />
(2) 含有辱骂、恐吓、威胁内容的；
<br />
(3) 含有骚扰、垃圾广告、恶意信息、诱骗信息的；
<br />
(4) 涉及他人隐私、个人信息或资料的；
<br />
(5) 破坏国家宗教政策，宣扬邪教和封建迷信的；
<br />
(6) 含有其他干扰本服务正常运营和侵犯其他用户或第三方合法权益内容的信息。
<br />

</p>
</div>

<div>
<h5 style="font-weight: bolder;font-size: 18px;color: #323232;padding-top: 10px;padding-bottom: 10px;">四、服务内容</h5>
<p style="color: #323232;font-size: 15px;line-height: 1.8;">
1．氢泡泡app具体服务内容由氢泡泡根据实际情况提供。
</p>
<p style="color: #323232;font-size: 15px;line-height: 1.8;">
2．氢泡泡有权随时审核或删除用户发布/传播的涉嫌违法或违反社会主义精神文明，或者被氢泡泡认为不妥当的内容（包括但不限于文字、语音、图片、视频、图文等）。
</p>
<p style="color: #323232;font-size: 15px;line-height: 1.8;">
3．所有发给用户的通告及其他消息都可通过APP或者用户所提供的联系方式发送。
</p>

</div>

<div>
<h5 style="font-weight: bolder;font-size: 18px;color: #323232;padding-top: 10px;padding-bottom: 10px;">五、服务的终止</h5>
<p style="color: #323232;font-size: 15px;line-height: 1.8;">
1．在下列情况下，氢泡泡有权终止向用户提供服务：
<br />
(1) 在用户违反本服务协议相关规定时，氢泡泡有权终止向该用户提供服务。如该用户再一次直接或间接或以他人名义注册为用户的，一经发现，氢泡泡有权直接单方面终止向该用户提供服务；
<br />
(2) 如氢泡泡通过用户提供的信息与用户联系时，发现用户在注册时填写的联系方式已不存在或无法接通，氢泡泡以其它联系方式通知用户更改，而用户在三个工作日内仍未能提供新的联系方式，氢泡泡有权终止向该用户提供服务；
<br />
(3) 一旦氢泡泡发现用户提供的数据或信息中含有虚假内容，氢泡泡有权随时终止向该用户提供服务；
<br />
(4) 本服务条款终止或更新时，用户明示不愿接受新的服务条款；
<br />
(5) 其它氢泡泡认为需终止服务的情况。
<br />

</p>
<p style="color: #323232;font-size: 15px;line-height: 1.8;">
2．服务终止后，氢泡泡没有义务为用户保留原账号中或与之相关的任何信息，或转发任何未曾阅读或发送的信息给用户或第三方。
</p>

</div>

<!--<div>
<h5 style="font-weight: bolder;font-size: 18px;color: #323232;padding-top: 10px;padding-bottom: 10px;">六、服务的终止</h5>
<p style="color: #323232;font-size: 15px;line-height: 1.8;">
1．您如对本协议项下蜗品商城服务有任何疑问，请登录获取相关信息或拨打本商城客服电话（020-37277399），蜗品商城将为您提供服务。服务时间：每周一至周五。每天9:30-12:00  13:30—17:30
</p>
<p style="color: #323232;font-size: 15px;line-height: 1.8;">
2．责任范围和限制<br />
<label>
（1）蜗品商城对不可抗力导致的损失不承担责任。本服务条款所指不可抗力包括：天灾、法律法规或政府指令的变更，因网络服务特性而特有的原因，例如境内外基础电信运营商的故障、计算机或互联网相关技术缺陷、互联网覆盖范围限制、计算机病毒、黑客攻击等因素，及其他合法范围内的不能预见、不能避免并不能克服的客观情况。
</label>
<br />
<label>
（2）您了解蜗品商城仅提供这一平台作为您获取商品或服务信息、物色交易对象、就商品和/或服务的交易进行协商及开展交易的非物理场所，但蜗品商城无法控制交易所涉及的物品的质量、安全或合法性，商贸信息的真实性或准确性，以及交易各方履行其在贸易协议中各项义务的能力。您应自行谨慎判断确定相关商品及/或信息的真实性、合法性和有效性，并自行承担因此产生的责任与损失。
</label>
<br />
<label>
（3）对发生下列情形之一所造成的不便或损害，蜗品商城免责：
<br />
<label>a&nbsp;&nbsp;定期检查或施工，更新软硬件而造成的服务中断，或突发性的软硬件设备与电子通信设备故障；</label>
<br />
<label>b&nbsp;&nbsp;您与其它任何第三方发生的纠纷。</label>
<br />
<label>c&nbsp;&nbsp;无论何种原因蜗品商城对您的购买行为的赔偿金额将不会超过您受到影响的当次购买行为已经实际支付的费用的总额。</label>
</label>
</p>
<p style="color: #323232;font-size: 15px;line-height: 1.8;">
3．服务终止。经国家行政或司法机关的生效法律文书确认您存在违法或侵权行为，或者蜗品商城根据自身的判断，认为您的行为涉嫌违反本协议的条款或涉嫌违反法律法规的规定的，则蜗品商城有权暂停或停止向您提供服务，且无须为此向您或任何第三方承担责任。
</p>
<p style="color: #323232;font-size: 15px;line-height: 1.8;">
4．本协议适用中华人民共和国的法律。 当本协议的任何内容与中华人民共和国法律相抵触时，应当以法律规定为准，同时相关条款将按法律规定进行修改或重新解释，而本协议其他部分的法律效力不变。
</p>
<p style="color: #323232;font-size: 15px;line-height: 1.8;">
5．如使用蜗品商城出现纠纷，您和蜗品商城一致同意将纠纷交由广州市蜗品贸易有限公司所在地人民法院管辖。
</p>
<p style="color: #323232;font-size: 15px;line-height: 1.8;">
6．蜗品商城有权对本协议进行调整、补充和改变，并有权以网页公告的方式予以公布，无需另行单独通知您。若您在蜗品商城进行上述调整、补充和改变后，仍继续使用蜗品商城服务的，则视为接受该等调整、补充和改变，若您不同意的，您有权终止本协议并停止使用蜗品商城服务。
</p>
<p style="color: #323232;font-size: 15px;line-height: 1.8;">
7．本协议自发布之日起实施，并构成您和蜗品商城之间的约定。
</p>
</div>-->
</div>

</div>
</div>
"""
    

}
