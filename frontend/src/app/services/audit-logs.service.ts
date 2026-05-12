import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

const API = environment.apiUrl;

export interface AuditLog {
  id?: number;

  fecha: string;

  accion:
    | 'LOGIN'
    | 'LOGOUT'
    | 'CREACION_CONTRATO'
    | 'AGREGAR_PARTICIPANTE'
    | 'ELIMINAR_PARTICIPANTE'
    | 'EDICION_CONTRATO'
    | 'FIRMA'
    | 'VALIDACION'
    | 'ERROR_VALIDACION_PROVEEDOR';

  contrato: string;

  usuario: string;

  detalles: string;
}

@Injectable({
  providedIn: 'root'
})
export class AuditLogsService {

  constructor(private http: HttpClient) {}

  getAll(filters?: {
    accion?: string;
    usuario?: string;
  }): Observable<AuditLog[]> {

    let params = new HttpParams();

    if (filters?.accion) {
      params = params.set('accion', filters.accion);
    }

    if (filters?.usuario) {
      params = params.set('usuario', filters.usuario);
    }

    return this.http.get<AuditLog[]>(
      `${API}/audit-logs`,
      { params }
    );
  }
}