//
//  ModeloAPI.swift
//  Xmount
//
//  Created by humberto Lima on 30/04/20.
//  Copyright © 2020 Crosoften. All rights reserved.
//

import Foundation

struct UsuarioLoginModel: Codable {
    var emails: String?
    var password: String?
}

struct UsuarioCadastroModel: Codable {
    var email: String?
    var name: String?
    var password: String?
}

struct UsarioLogadoModel: Codable {
    var id: Int?
}

class BaseApi: NSObject {
    
    let servidor = "URL SERVIDOR "
    var usuarioLogado = UsarioLogadoModel()
   
    func requestBase(dataEnviar: Data?, urlEnviar: String, headerEnviar:[String: String], tipoEnvio: String, onSuccess:@escaping(Bool, Data?) -> Void) {
        let urlTeste = urlEnviar.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
        var request = URLRequest(url: URL(string: "\(servidor)\(urlTeste)")!)
        request.httpMethod = tipoEnvio
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        
        if dataEnviar != nil { request.httpBody = dataEnviar }
        if headerEnviar != ["":""] { request.allHTTPHeaderFields = headerEnviar }
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest) {jsonRet,response,error in
            DispatchQueue.main.async {
                let httpResponse = response as? HTTPURLResponse
                if httpResponse?.statusCode == 200 || httpResponse?.statusCode == 201 {
                    onSuccess(true, jsonRet)
                }else{
                    print("Erro -> \(String(describing: httpResponse?.statusCode))")
                    onSuccess(false, Data())
                }
            }
        }
        dataTask.resume()
    }
    
    
    func postLoginApp(loginUsuario: UsuarioLoginModel, onSuccess:@escaping(Bool, String) -> Void) {
        let encoder = JSONEncoder()
        let jsonEnviar = try! encoder.encode(loginUsuario)
        self.requestBase(dataEnviar: jsonEnviar, urlEnviar: "/login", headerEnviar: ["":""], tipoEnvio: "POST") { (ret, datRet) in
            if ret {
                if let temp = try? JSONDecoder().decode(UsarioLogadoModel.self, from: datRet!) {
                    self.usuarioLogado = temp
                    onSuccess(true, "")
                }else{
                    onSuccess(false, "Erro 7.1 \n Ocorreu um erro ao se conectar com o servidor, verifique sua conexão com a internet e tente novamente.")
                }
            }else{
                onSuccess(false, "Erro 7.3 \n Ocorreu um erro ao se conectar com o servidor, verifique sua conexão com a internet e tente novamente.")
            }
        }
    }
}
