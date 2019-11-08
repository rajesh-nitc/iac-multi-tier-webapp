import { Component } from '@angular/core';
import { HttpService } from './http.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent {
  resFromServer:any
  resFromDatabase:any
  constructor(private httpService: HttpService) { }

  ngOnInit(): void {
    this.httpService.testServerConnection().subscribe((res:any) => {
      console.log(res);
      this.resFromServer = res.msg
    })

    this.httpService.testDatabaseConnection().subscribe((res:any) => {
      console.log(res);
      if(res.length == 0){
        this.resFromDatabase = "oops! no msgs in the database"
      } else {
        this.resFromDatabase = `First msg is ${res[0].msg}`
      }
      
    })
  }

}