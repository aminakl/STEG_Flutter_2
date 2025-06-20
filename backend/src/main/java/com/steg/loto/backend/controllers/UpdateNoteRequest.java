package com.steg.loto.backend.controllers;

import com.steg.loto.backend.models.LockoutNote;
import java.time.LocalDateTime;
import jakarta.validation.constraints.NotNull;
import com.fasterxml.jackson.annotation.JsonFormat;

public class UpdateNoteRequest {
    private String posteHt;
    private LockoutNote.EquipmentType equipmentType;
    private String equipmentDetails;
    private String uniteSteg;
    private String workNature;
    private LocalDateTime retraitDate;
    private LocalDateTime debutTravaux;
    private LocalDateTime finTravaux;
    private LocalDateTime retourDate;
    private Integer joursIndisponibilite;
    private String chargeRetrait;
    private String chargeConsignation;
    private String chargeTravaux;
    private String chargeEssais;
    private String instructionsTechniques;
    private String destinataires;
    private String coupureDemandeePar;
    private String noteTransmiseA;

    // Getters and setters
    public String getPosteHt() {
        return posteHt;
    }

    public void setPosteHt(String posteHt) {
        this.posteHt = posteHt;
    }

    public LockoutNote.EquipmentType getEquipmentType() {
        return equipmentType;
    }

    public void setEquipmentType(LockoutNote.EquipmentType equipmentType) {
        this.equipmentType = equipmentType;
    }

    public String getEquipmentDetails() {
        return equipmentDetails;
    }

    public void setEquipmentDetails(String equipmentDetails) {
        this.equipmentDetails = equipmentDetails;
    }

    public String getUniteSteg() {
        return uniteSteg;
    }

    public void setUniteSteg(String uniteSteg) {
        this.uniteSteg = uniteSteg;
    }

    public String getWorkNature() {
        return workNature;
    }

    public void setWorkNature(String workNature) {
        this.workNature = workNature;
    }

    public LocalDateTime getRetraitDate() {
        return retraitDate;
    }

    public void setRetraitDate(LocalDateTime retraitDate) {
        this.retraitDate = retraitDate;
    }

    public LocalDateTime getDebutTravaux() {
        return debutTravaux;
    }

    public void setDebutTravaux(LocalDateTime debutTravaux) {
        this.debutTravaux = debutTravaux;
    }

    public LocalDateTime getFinTravaux() {
        return finTravaux;
    }

    public void setFinTravaux(LocalDateTime finTravaux) {
        this.finTravaux = finTravaux;
    }

    public LocalDateTime getRetourDate() {
        return retourDate;
    }

    public void setRetourDate(LocalDateTime retourDate) {
        this.retourDate = retourDate;
    }

    public Integer getJoursIndisponibilite() {
        return joursIndisponibilite;
    }

    public void setJoursIndisponibilite(Integer joursIndisponibilite) {
        this.joursIndisponibilite = joursIndisponibilite;
    }

    public String getChargeRetrait() {
        return chargeRetrait;
    }

    public void setChargeRetrait(String chargeRetrait) {
        this.chargeRetrait = chargeRetrait;
    }

    public String getChargeConsignation() {
        return chargeConsignation;
    }

    public void setChargeConsignation(String chargeConsignation) {
        this.chargeConsignation = chargeConsignation;
    }

    public String getChargeTravaux() {
        return chargeTravaux;
    }

    public void setChargeTravaux(String chargeTravaux) {
        this.chargeTravaux = chargeTravaux;
    }

    public String getChargeEssais() {
        return chargeEssais;
    }

    public void setChargeEssais(String chargeEssais) {
        this.chargeEssais = chargeEssais;
    }

    public String getInstructionsTechniques() {
        return instructionsTechniques;
    }

    public void setInstructionsTechniques(String instructionsTechniques) {
        this.instructionsTechniques = instructionsTechniques;
    }

    public String getDestinataires() {
        return destinataires;
    }

    public void setDestinataires(String destinataires) {
        this.destinataires = destinataires;
    }

    public String getCoupureDemandeePar() {
        return coupureDemandeePar;
    }

    public void setCoupureDemandeePar(String coupureDemandeePar) {
        this.coupureDemandeePar = coupureDemandeePar;
    }

    public String getNoteTransmiseA() {
        return noteTransmiseA;
    }

    public void setNoteTransmiseA(String noteTransmiseA) {
        this.noteTransmiseA = noteTransmiseA;
    }
}
