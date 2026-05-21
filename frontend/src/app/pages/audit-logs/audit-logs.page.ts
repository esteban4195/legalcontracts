import { Component, OnInit } from "@angular/core";
import { CommonModule } from "@angular/common";
import { FormsModule } from "@angular/forms";
import { AuditLogsService, AuditLog } from "../../services/audit-logs.service";

@Component({
  selector: "app-audit-logs",
  templateUrl: "audit-logs.page.html",
  styleUrls: ["audit-logs.page.scss"],
  standalone: true,
  imports: [CommonModule, FormsModule],
})
export class AuditLogsPage implements OnInit {
  // Simulación temporal de logs a espera de backend (Nasly)
  logs: AuditLog[] = [];
  filteredLogs: AuditLog[] = [];

  constructor(private auditLogsService: AuditLogsService) {}

  selectedAction: string = "";
  selectedUser: string = "";

  isForbidden = false;
  isLoading = false;

  get totalEventos(): number {
    return this.logs.length;
  }

  get totalFirmas(): number {
    return this.logs.filter((log) => log.action_type === "FIRMA").length;
  }

  get totalValidaciones(): number {
    return this.logs.filter((log) => log.action_type === "VALIDACION").length;
  }

  ngOnInit(): void {

  this.isLoading = true;

  this.auditLogsService.getAll().subscribe({

    next: (resp) => {

      this.logs = resp;
      this.filteredLogs = [...resp];

      this.isLoading = false;
    },

    error: (err) => {

      this.isLoading = false;

      if (err.status === 403) {
        this.isForbidden = true;
      }
    }
  });
}

  applyFilters(): void {
    this.filteredLogs = this.logs.filter((log) => {
      const matchAction =
        !this.selectedAction ||
        log.action_type.toLowerCase().includes(this.selectedAction.toLowerCase());

      const matchUser =
        !this.selectedUser ||
        log.user_name.toLowerCase().includes(this.selectedUser.toLowerCase());

      return matchAction && matchUser;
    });
  }

  getActionClass(actionType: string): string {
    const map: Record<string, string> = {
      LOGIN: "badge-login",
      LOGOUT: "badge-logout",
      FIRMA: "badge-sign",
      ACTUALIZACION_FIRMA: "badge-sign",
      VALIDACION: "badge-validation",
      CREACION_CONTRATO: "badge-create",
      AGREGAR_PARTICIPANTE: "badge-add",
      ELIMINAR_PARTICIPANTE: "badge-remove",
      EDICION_CONTRATO: "badge-edit",
      ERROR_VALIDACION_PROVEEDOR: "badge-error",
    };
    return map[actionType] ?? "badge-default";
  }
}
