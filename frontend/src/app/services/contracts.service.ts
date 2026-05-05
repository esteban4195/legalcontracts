import { Injectable } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';

const API = environment.apiUrl;

export interface ContractCreator {
  id: number;
  name: string;
}

export interface ContractProvider {
  id: number;
  name: string;
}

export interface ContractParticipant {
  id: number;
  user_id: number;
  user_name: string;
  user_email: string;
  user_system_role: string;
  role_in_contract: 'CLIENTE' | 'PROVEEDOR' | 'TESTIGO';
  has_signed: boolean;
  signed_at: string | null;
}

export interface BlockchainBlock {
  id: number;
  block_number: number;
  event_type: 'GENESIS' | 'FIRMA' | 'VALIDACION';
  data_json: string;
  previous_hash: string | null;
  hash: string;
  created_by_user_id: number;
  created_at: string;
}

export interface Contract {
  id: number;
  title: string;
  status: 'BORRADOR' | 'FIRMADO' | 'VALIDADO';
  contains_sensitive_data: boolean;
  created_at: string;
  created_by: ContractCreator;
  cloud_provider: ContractProvider;
  total_participants: number;
  signed_participants: number;
}

export interface ContractDetail extends Contract {
  content: string;
  updated_at: string;
  participants: ContractParticipant[];
  blockchain_blocks: BlockchainBlock[];
}

@Injectable({ providedIn: 'root' })
export class ContractsService {
  constructor(private http: HttpClient) {}

  getAll(filters?: { status?: string; title?: string; cloud_provider_id?: number }): Observable<Contract[]> {
    let params = new HttpParams();
    if (filters?.status) params = params.set('status', filters.status);
    if (filters?.title) params = params.set('title', filters.title);
    if (filters?.cloud_provider_id) params = params.set('cloud_provider_id', String(filters.cloud_provider_id));
    return this.http.get<Contract[]>(`${API}/contracts`, { params });
  }

  getById(id: number): Observable<ContractDetail> {
    return this.http.get<ContractDetail>(`${API}/contracts/${id}`);
  }

  create(payload: {
    title: string;
    content: string;
    contains_sensitive_data: boolean;
    cloud_provider_id: number;
    participants: { user_id: number; role_in_contract: string }[];
  }): Observable<ContractDetail> {
    return this.http.post<ContractDetail>(`${API}/contracts`, payload);
  }

  update(id: number, payload: {
    title?: string;
    content?: string;
    contains_sensitive_data?: boolean;
    cloud_provider_id?: number;
    participants?: { user_id: number; role_in_contract: string }[];
  }): Observable<ContractDetail> {
    return this.http.put<ContractDetail>(`${API}/contracts/${id}`, payload);
  }

  sign(id: number): Observable<ContractDetail> {
    return this.http.post<ContractDetail>(`${API}/contracts/${id}/sign`, {});
  }

  validate(id: number): Observable<ContractDetail> {
    return this.http.post<ContractDetail>(`${API}/contracts/${id}/validate`, {});
  }
}
