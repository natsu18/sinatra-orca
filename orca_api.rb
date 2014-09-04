#!/usr/bin/ruby
# -*- coding: utf-8 -*-

#------ 患者番号一覧取得


require 'uri'
require 'net/http'
require 'pp'
require 'crack'
require 'crack/xml'

def post(url,opt,body)
  req=Net::HTTP::Post.new(url)
  req.content_length = body.size
  req.content_type = "application/xml"
  req.body = body
  req.basic_auth(opt[:user],opt[:passwd])

  ret=[]
  Net::HTTP.start(opt[:host],opt[:port]) {|http|
    res = http.request(req)
    ret = [res.code,res.body]
  }
  ret
end

def list_patients(opt)
  url="/api01rv2/patientlst1v2?class=01"
  body=<<-EOF
  <data>
     <patientlst1req type="record">
     <Base_StartDate type="string">2000-01-01</Base_StartDate>
     <Base_EndDate type="string">#{Time.now.strftime("%Y-%m-%d")}</Base_EndDate>
     <Contain_TestPatient_Flag type="string">1</Contain_TestPatient_Flag>
     </patientlst1req>
  </data>
  EOF

  ret=post(url,opt,body)
  if ret.empty?
     puts "ret empty"
    return []
  end
  unless ret[0]=="200"
    puts "status code:#{ret[0]}"
    return []
  end

    root=Crack::XML.parse(ret[1])
    result=root["xmlio2"]["patientlst1res"]["Api_Result"]
    unless result=="00"
      puts "error"
      return []
    end
    root["xmlio2"]["patientlst1res"]["Patient_Information"]
end

def register_patient(opt,params)
  url="/orca12/patientmodv2?class=01"
  body = <<-EOF
  <data>
        <patientmodreq type="record">
                <Patient_ID type="string">*</Patient_ID>
                <WholeName type="string">#{params['whole_name']}</WholeName>
                <WholeName_inKana type="string">#{params['whole_name_kana']}</WholeName_inKana>
                <BirthDate type="string">#{params['birth_date']}</BirthDate>
                <Sex type="string">#{params['sex']}</Sex>
                <HouseHolder_WholeName type="string">#{params['whole_name']}</HouseHolder_WholeName>
                <Relationship type="string">本人</Relationship>
                <Occupation type="string">会社員</Occupation>
                <CellularNumber type="string">09011112222</CellularNumber>
                <FaxNumber type="string">03-0011-2233</FaxNumber>
                <EmailAddress type="string">test@tt.dot.jp</EmailAddress>
                <Home_Address_Information type="record">
                        <Address_ZipCode type="string">1130021</Address_ZipCode>
                        <WholeAddress1 type="string">東京都文京区本駒込</WholeAddress1>
                        <WholeAddress2 type="string">６−１６−３</WholeAddress2>
                        <PhoneNumber1 type="string">03-3333-2222</PhoneNumber1>
                        <PhoneNumber2 type="string">03-3333-1133</PhoneNumber2>
                </Home_Address_Information>
                <!--
                <WorkPlace_Information type="record">
                        <WholeName type="string">てすと　株式会社</WholeName>
                        <Address_ZipCode type="string">1130022</Address_ZipCode>
                        <WholeAddress1 type="string">東京都文京区本駒込</WholeAddress1>
                        <WholeAddress2 type="string">５−１２−１１</WholeAddress2>
                        <PhoneNumber type="string">03-3333-2211</PhoneNumber>
                </WorkPlace_Information>
                <Contraindication1 type="string">状態</Contraindication1>
                <Allergy1 type="string">アレルギ</Allergy1>
                <Infection1 type="string">感染症</Infection1>
                <Comment1 type="string">コメント</Comment1>
                <HealthInsurance_Information type="record">
                        <InsuranceProvider_Class type="string">060</InsuranceProvider_Class>
                        <InsuranceProvider_Number type="string">138057</InsuranceProvider_Number>
                        <InsuranceProvider_WholeName type="string">国保</InsuranceProvider_WholeName>
                        <HealthInsuredPerson_Symbol type="string">０１</HealthInsuredPerson_Symbol>
                        <HealthInsuredPerson_Number type="string">１２３４５６７</HealthInsuredPerson_Number>
                        <RelationToInsuredPerson type="string">1</RelationToInsuredPerson>
                        <Certificate_StartDate type="string">2010-05-01</Certificate_StartDate>
                        <PublicInsurance_Information type="array">
                                <PublicInsurance_Information_child type="record">
                                        <PublicInsurance_Class type="string">010</PublicInsurance_Class>
                                        <PublicInsurance_Name type="string">感３７の２</PublicInsurance_Name>
                                        <PublicInsurer_Number type="string">10131142</PublicInsurer_Number>
                                        <PublicInsuredPerson_Number type="string">1234566</PublicInsuredPerson_Number>
                                        <Certificate_IssuedDate type="string">2010-05-01</Certificate_IssuedDate>
                                </PublicInsurance_Information_child>
                        </PublicInsurance_Information>
                </HealthInsurance_Information>
                -->
        </patientmodreq>
</data>
EOF

  ret=post(url,opt,body)
  if ret.empty?
     puts "ret empty"
    return [nil,"http post error"]
  end
  unless ret[0]=="200"
    puts "status code:#{ret[0]}"
    return [nil,"status code:#{ret[0]}"]
  end

    root=Crack::XML.parse(ret[1])
    result =root["xmlio2"]["patientmodres"]["Api_Result"]
    message=root["xmlio2"]["patientmodres"]["Api_Result_Message"]
    unless result=="00"
      puts "result:#{result} message:#{message}"
      return [nil,"result:#{result} message:#{message}"]
    end
    pinfo=root["xmlio2"]["patientmodres"]["Patient_Information"]
    id=pinfo["Patient_ID"]
    [id,nil]
end


def delete_patient(opt,params)
  url="/orca12/patientmodv2?class=03"
  body = <<-EOF
  <data>
        <patientmodreq type="record">
                <Patient_ID type="string">#{params['id']}</Patient_ID>
                <WholeName type="string">#{params['whole_name']}</WholeName>
                <WholeName_inKana type="string">#{params['whole_name_kana']}</WholeName_inKana>
                <BirthDate type="string">#{params['birth_date']}</BirthDate>
                <Sex type="string">#{params['sex']}</Sex>
        </patientmodreq>
</data>
EOF

  ret=post(url,opt,body)
  if ret.empty?
     puts "ret empty"
    return [nil,"http post error"]
  end
  unless ret[0]=="200"
    puts "status code:#{ret[0]}"
    return [nil,"status code:#{ret[0]}"]
  end

    root=Crack::XML.parse(ret[1])
    result =root["xmlio2"]["patientmodres"]["Api_Result"]
    message=root["xmlio2"]["patientmodres"]["Api_Result_Message"]
    unless result=="00"
      puts "result:#{result} message:#{message}"
      return [nil,"result:#{result} message:#{message}"]
    end
    pinfo=root["xmlio2"]["patientmodres"]["Patient_Information"]
    id=pinfo["Patient_ID"]
    [id,"削除しました"]
end
