import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from '../../environments/environment';


export interface RecentContract {
    id: number;
    title: string;
    status: string;
    provider: string;
    created_at: string;
}

export interface MonthlyCount {
    month: number;
    total: number;
}

export interface RecentActivity {
    action_type: string;
    description: string;
    user_name: string;
    contract_title: string;
    created_at: string;
}

export interface DashboardSummary {
    total_contracts: number;
    signed_contracts: number;
    draft_contracts: number;
    validated_contracts: number;
    active_users: number;
    active_cloud_providers: number;
    recent_contracts: RecentContract[];
    contracts_by_month: MonthlyCount[];
    recent_activity: RecentActivity[];
}

@Injectable({
    providedIn: 'root'
})
export class DashboardService {
    private apiUrl = environment.apiUrl || 'http://localhost:8000';

    constructor(private http: HttpClient) { }

    getSummary(): Observable<DashboardSummary> {
        return this.http.get<DashboardSummary>(`${this.apiUrl}/dashboard/summary`);
    }
}