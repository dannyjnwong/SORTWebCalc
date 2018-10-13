
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(dplyr)
library(tidyr)
library(DT)

procedures <- read.csv("SNAP2_procedurelist.csv", stringsAsFactors = FALSE)

shinyServer(function(input, output) {
  
  out_tab <- reactive({
    
    procedures %>% filter(SurgeryProcedure %in% input$Procedure) %>%
      select(SurgeryProcedure, SurgeryProcedureSeverity) %>%
      mutate(ASA = input$ASA) %>%
      mutate(Urgency = input$Urgency) %>%
      mutate(Specialty = input$Specialty) %>%
      mutate(Malignancy = input$Malignancy) %>%
      mutate(Age = input$Age) %>%
      mutate(SORT_morb_logit = ((ASA == "2") * 0.332 +
                                  (ASA == "3") * 1.140 + 
                                  (ASA == "4") * 1.223 +
                                  (ASA == "5") * 1.223 +
                                  (Specialty == "Colorectal") * 1.658 +
                                  (Specialty == "UpperGI") * -0.929 +
                                  (Specialty == "Vascular") * 0.296 +
                                  (Specialty == "Bariatric") * -1.065 +
                                  (!(Specialty %in% c("Colorectal", "UpperGI", "Vascular", "Bariatric", "Orthopaedic"))) * 0.181 +
                                  (SurgeryProcedureSeverity == "Xma") * 1.238 + 
                                  (SurgeryProcedureSeverity == "Com") * 1.238 +
                                  (Malignancy == "Yes") * 0.897 + 
                                  (Age == "65-79") * 0.118 + 
                                  (Age == ">80") * 0.550 -
                                  3.228)) %>%
      mutate(SORT_mort_logit = ((ASA == "3") * 1.411 +
                                  (ASA == "4") * 2.388 +
                                  (ASA == "5") * 4.081 +
                                  (Urgency == "Expedited") * 1.236 +
                                  (Urgency == "Urgent") * 1.657 +
                                  (Urgency == "Immediate") * 2.452 +
                                  (Specialty %in% c("Colorectal", "UpperGI", "Bariatric", "HPB", "Thoracic", "Vascular")) * 0.712 +
                                  (SurgeryProcedureSeverity %in% c("Xma", "Com")) * 0.381 +
                                  (Malignancy == "Yes") * 0.667 +
                                  (Age == "65-79") * 0.777 +
                                  (Age == ">80") * 1.591 -
                                  7.366)) %>%
      mutate(POMS_Risk = arm::invlogit(SORT_morb_logit)) %>%
      mutate(Low_grade = arm::invlogit(SORT_morb_logit * 1.008 - 0.316)) %>%
      mutate(High_grade = arm::invlogit(SORT_morb_logit * 0.827 - 0.874)) %>%
      mutate(Day14 = arm::invlogit(SORT_morb_logit * 0.894 - 1.478)) %>%
      mutate(Day21 = arm::invlogit(SORT_morb_logit * 1.081 - 2.327)) %>%
      mutate(Day28 = arm::invlogit(SORT_morb_logit * 1.048 - 2.770)) %>%
      mutate(SORT_mortality = arm::invlogit(SORT_mort_logit)) %>%
      select(POMS_Risk:SORT_mortality) %>%
      rename(`D7 POMS` = "POMS_Risk",
             `D7 Low-grade POMS` = "Low_grade",
             `D7 High-grade POMS` = "High_grade",
             `D14 POMS` = "Day14",
             `D21 POMS` = "Day21",
             `D28 POMS` = "Day28",
             `D30 Mortality (SORT)` = "SORT_mortality")
    
  })

  output$Table <- renderDT({
    
    out_tab() %>%
      gather(key = "Outcome", value = "Risk") %>%
      datatable(options = list(dom = 't'), rownames = FALSE) %>% 
      formatPercentage(digits = 2,
                       c("Risk"))
    
  })

})
