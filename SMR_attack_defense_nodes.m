% import the table of attack nodes and regulatory guide recourse actions
% for the SMR station 

SMR=readtable("SMR_attack_node_table.xlsx");


%=======   Determine risk associated with each attack node determined as
%the number of maintenance actions will trigger the attack node =====% 

% List of maintenance columns
maintenanceCols = {
    'x1_SpentFuelReplacement', 
    'x2_RelayAndProtectionSystemCalibration', 
    'x3_PrimaryCoolingSystemMaintenance', 
    'x4_SpentFuelPoolMonitoringAndMaintenance', 
    'x5_AncillaryServicesAndFunctionalTesting'
};

% Initialize the count
MaintenanceX = zeros(height(SMR), 1);

% Loop over maintenance columns
for c = 1:length(maintenanceCols)
    col = maintenanceCols{c};
    MaintenanceX = MaintenanceX + strcmp(SMR.(col), 'X');
end

% Add to table if desired
SMR.MaintenanceCount = MaintenanceX;


% =====    Count the number of Minimal, Partial, and Total recourse action
% coverage available for each attack node ========% 
% list of regulatory guides and actions to mitigate attacks

recourseCols={'NERC_NUC_001_4_R1_R5_NuclearPlantInterfaceRequirements_NPIRs_Co',
    'NERC_NUC_001_4_R6_R7_GeneratorOperatorMustCoordinateAllMaintena',
    'NERC_NUC_001_4_R8_TransmissionEntitiesMustCoordinateAllChangesT',
    'NERC_CIP_006_6_R1_R2_VistorContolProgramsThatRequireEscortsAndA',
    'NERC_CIP_004_7_R1_R2_CybersecurityTrainingAndSecurityAwarenessT',
    'NERC_CIP_004_7_R3_PersonnelRiskAssessmentProgramMustBeInPlaceFo',
    'NERC_CIP_004_7_R4_R6_AccessManagementProgramForAllPhysicalLocat',
    'NERC_FAC_014_3_R4_R5_StablilityLimits_voltageAndFrequency_Shoul',
    'NERC_FAC_014_3_R6_R7_TransmissionPlanningAndOperationsShouldPro',
    'NERC_PRC_001_CoordinateBetweenTransmissionEntities_TO_TOP_ISO_T',
    'NERC_PRC_005_CoordinateBetweenTransmissionEntities_TO_TOP_ISO_T'
};

Mcount = zeros(height(SMR), 1);
Pcount = zeros(height(SMR), 1);
Tcount = zeros(height(SMR), 1);


for c = 1:length(recourseCols)
    col = recourseCols{c};
    
    Mcount = Mcount + strcmp(SMR.(col), 'M');
    Pcount = Pcount + strcmp(SMR.(col), 'P');
    Tcount = Tcount + strcmp(SMR.(col), 'T');
end

SMR.NumM = Mcount;
SMR.NumP = Pcount;
SMR.NumT = Tcount;


isTerminal = SMR.TerminalAttackNodes_PointsOfIngress_;


%  ========== Determine the attack nodes of high risk (large number of
%  maintenance scenario triggeres) and low coverage (no total T coverage
%  available) ;
HighRisk = SMR.MaintenanceCount >= 3 & SMR.NumT<1 & strcmp(isTerminal, 'X');

CriticalNodesList = SMR(HighRisk,:);
figure(3)
bar(CriticalNodesList.MaintenanceCount)
xticklabels(CriticalNodesList.NodeLabel)
xlabel('Attack Node')
ylabel('# Maintenance Scenarios Triggering Node')
title('High-Risk, Low-Coverage SMR Attack Nodes')

% Extract relevant data
nodeLabels = CriticalNodesList.NodeLabel;
yData = [CriticalNodesList.MaintenanceCount, CriticalNodesList.NumM, CriticalNodesList.NumP, CriticalNodesList.NumT];

% Create grouped bar chart
figure();
bar(yData, 'grouped');

% Labeling
xticks(1:length(nodeLabels));
xticklabels(nodeLabels);
xtickangle(45);
ylabel('Count');
legend({'Maintenance Count', 'M Count', 'P Count'});
title('High-Risk Attack Nodes: Maintenance Exposure and Regulatory Coverage');
grid on;
M
b = bar(yData, 'grouped');
b(1).FaceColor = [0.2, 0.2, 0.8];  % Maintenance Count - Blue
b(2).FaceColor = [0.9, 0.6, 0.0];  % M Count - Orange
b(3).FaceColor = [0.6, 0.8, 0.2];  % P Count - Green
legend({'Maintenance Count', 'M Count', 'P Count'});
xlabel('Attack Node')
ylabel('# Actions Triggering Node')
title('High-Risk Attack Nodes: Maintenance Exposure and Regulatory Coverage');