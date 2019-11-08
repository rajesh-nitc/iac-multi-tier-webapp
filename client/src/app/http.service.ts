import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { environment } from 'src/environments/environment.prod';

@Injectable({
  providedIn: 'root'
})
export class HttpService {

  constructor(private http: HttpClient) { }

  testServerConnection(){
    return this.http.get(environment.webapp_server + "/api")
  }

  testDatabaseConnection(){
    return this.http.get(environment.webapp_server + "/api/getmsg")
  }
}
