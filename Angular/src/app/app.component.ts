import { Component } from '@angular/core';
import { AppService } from './app.service';
import { saveAs } from 'file-saver';


@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent {
  constructor(private appService: AppService) { }

  EditorOptions = {
    theme: "vs-dark",
    automaticLayout: true,
    scrollBeyondLastLine: false,
    fontSize: 16,
    minimap: {
      enabled: true
    },
    language: 'java'
  }

  ConsoleOptions = {
    theme: "vs-dark",
    readOnly: true,
    automaticLayout: true,
    scrollBeyondLastLine: false,
    fontSize: 16,
    minimap: {
      enabled: true
    },
    language: ''
  }

  title = 'Syscompiler';
  entrada: string = '';
  salida: string = '';
  fname: string = '';
  simbolos: any = [];
  errores: any = [];

  nuevaventana() {
    window.open("/", "_blank");
  }

  cerrarventana() {
    window.close();
  }

  onSubmit() {

    if (this.entrada != "") {

      const x = { "input": this.entrada }

      this.appService.compile(x).subscribe(

        data => {

          console.log('Datos recibidos');

          this.salida = data.output;

          this.simbolos = data.arreglo_simbolos;

          this.errores = data.arreglo_errores;
        },

        error => {

          console.log('There was an error :(', error);
          this.simbolos = [];

          this.errores = [];

          if (error.error) {

            if (error.error.output)

              this.salida = error.error.output;

            else if (error.error.message)

              this.salida = error.error.message;

            else

              this.salida = error.error;

          }
          else {

            this.salida = "Ocurrió un error desconocido.\nIngrese otra entrada.";

          }

        }
      );
    } else

      this.salida = "Entrada vacía. Intente de nuevo.";
  }

  getAST() {

    this.simbolos = [];

    this.errores = [];

    if (this.entrada != "") {

      const x = { "input": this.entrada }

      this.appService.getAST(x).subscribe(

        data => {

          saveAs(data, "AST");

          this.salida = "Reporte AST generado con exito";

          console.log('AST recibido');

        },
        error => {

          console.log('There was an error :(', error);

          this.salida = "Ocurrió un error al analizar la entrada.\nNo se generó el AST."

        }
      );

    } else

      alert("Entrada vacía. No se puede generar el AST.");

  }

  guardar() {

    var f = document.createElement('a');

    f.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(this.entrada));

    f.setAttribute('download', this.fname ? this.fname.replace("C:\\fakepath\\", "") : 'ArchivoGuardado.sc');
    
    if (document.createEvent) {
      
      var event = document.createEvent('MouseEvents');

      event.initEvent('click', true, true);

      f.dispatchEvent(event);

    }

    else {

      f.click();

    }
    console.log('Archivo Guardado con exito');

  }

  openDialog() {

    document.getElementById("fileInput")!.click();

  }

  readFile(event: any) {

    let input = event.target;

    let reader = new FileReader();

    reader.onload = () => {

      var text = reader.result;
      if (text) {
        this.entrada = text.toString();
      }
    }



    reader.readAsText(input.files[0]);
    this.salida = '';

    console.log('Archivo abierto con exito')
  }
  limpiar(){



    this.entrada = "";

    this.salida = "";
  }
  cambioblanco(){
    
     this.EditorOptions = {
      theme: "vs",
      automaticLayout: true,
      scrollBeyondLastLine: false,
      fontSize: 16,
      minimap: {
        enabled: true
      },
      language: 'java'
    }
  }

  cambioscuro(){
    this.EditorOptions = {
     theme: "vs-dark",
     automaticLayout: true,
     scrollBeyondLastLine: false,
     fontSize: 16,
     minimap: {
       enabled: true
     },
     language: 'java'
   }
 }
 cambiocontraste(){
  this.EditorOptions = {
    theme: "hc-black",
    automaticLayout: true,
    scrollBeyondLastLine: false,
    fontSize: 16,
    minimap: {
      enabled: true
    },
    language: 'java'
  }


 }
}
