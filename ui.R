
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(DT)

procedures_list <- read.csv("SNAP2_procedurelist.csv", stringsAsFactors = FALSE)

# Sidebar with a number of inputs
shinyUI(fluidPage(

  # Application title
  titlePanel("Surgical Outcome Risk Tool (SORT) Web Calculator v.0.6"),
  p("Disclaimer: The SORT uses some information about patient health and the planned surgical procedure to provide an estimate of the risk of death within 30 days of an operation. The SORT has been extended to predict postoperative morbidity (SORT-morbidity). For more information about SORT and SORT-morbidity, please read the papers below."), 
  p("The percentages provided by the calculator are only estimates taking into account the general risks of the procedure and some information about the patient, but should not be confused with a patient-specific estimate in an individual case. As with all risk prediction tools, not every factor which may affect outcome can be included, and there may well be other patient-specific and surgical factors which may influence the risk of death or complications significantly. This resource is not intended to be used in isolation for clinical decision making and should not replace the advice of a healthcare professional about the potential risks or benefits of a planned procedure. The author of this calculator will not be held responsible for decisions made by healthcare professionals or patients which are based on the estimates provided by the SORT, as these estimates are provided only for the purposes of background information."),
  p("Patients should always consult a healthcare professional in decision-making about their health and treatment."),
  a(href="http://dx.doi.org/10.1002/bjs.9638", "1. KL Protopapa, JC Simpson, NCE Smith, SR Moonesinghe; Development and validation of the Surgical Outcome Risk Tool (SORT). Br J Surg. 2014 Dec;101(13):1774–83. doi: 10.1002/bjs.9638"),
  p(""),
  a(href="https://doi.org/10.1093/bja/aex117", "2. DJN Wong, CM Oliver, SR Moonesinghe; Predicting postoperative morbidity in adult elective surgical patients using the Surgical Outcome Risk Tool (SORT). Br J Anaesth 2017;119(1):95-105. doi: 10.1093/bja/aex117"),
  p(""),
  a(href="https://journals.plos.org/plosmedicine/", "3. DJN Wong, SK Harris, A Sahni, JR Bedford, L Cortes, R Shawyer, AM Wilson, HA Lindsay, D Campbell, S Popham, LM Barneto, PS Myles, SNAP-2: EPICCS collaborators, SR Moonesinghe. Developing and validating subjective and objective risk assessment measures for predicting mortality after major surgery: an international prospective cohort study. PLOS Medicine 2020 (accepted, in press)."),
  p(""),
  p("MIT License; Copyright (c) 2017-2020 Danny Jon Nian Wong."), 
  a(href="https://github.com/dannyjnwong/SORTWebCalc", "Source code available here on Github."),

  # Sidebar with inputs
  sidebarLayout(
    sidebarPanel(
      
      #Clinical Assessment
      radioButtons("Clinical", "What is your subjective clinical assessment of the patient's risk?",
                   choices = c("<1%", "1-2.5%", "2.6-5%", "5.1-10%", "10.1-50%", ">50%", "Don't know"),
                   inline = TRUE),
      
      #Surgical Procedure
      selectizeInput("Procedure", "Search for Procedure",
                     choices = list("Type in a procedure" = "", "Procedures" = procedures_list$SurgeryProcedure)),
      
      #ASA
      radioButtons("ASA", "ASA-PS class", 
                   choices = c("1", "2", "3", "4", "5"),
                   inline = TRUE),
      
      #Urgency (not included in SORT-morbidity)
      radioButtons("Urgency", "Surgical urgency (only used to calculate D30 mortality risk)", 
                   choices = c("Elective", "Expedited", "Urgent", "Immediate"),
                   inline = TRUE),
      
      #Specialty
      radioButtons("Specialty", "Surgical specialty", 
                   choices = c("Orthopaedic", "Colorectal", "Upper GI", "Bariatric", "HPB", "Thoracic", "Vascular", "Other"),
                   inline = TRUE),
      
      #Malignancy
      radioButtons("Malignancy", "Does the patient have a malignancy?", 
                   choices = c("Yes", "No"),
                   inline = TRUE),
      
      #Age
      radioButtons("Age", "What is the patient's age?",
                   choices = c("<65", "65-79", ">80"),
                   inline = TRUE),
      
      #Action button
      actionButton("Compute", "Calculate Risks!")
      
    ),

    # Show a table output
    mainPanel(
      
      tags$style(type="text/css",
                 ".shiny-output-error { visibility: hidden; }",
                 ".shiny-output-error:before { visibility: hidden; }"),
      
      tabsetPanel(type = "tabs",
                  tabPanel("Risk Table", 
                           DTOutput("Table")),
                  tabPanel("Waffle Plots", 
                           plotOutput("MorbWaffle"),
                           plotOutput("MortWaffle"),
                           plotOutput("CombinedMortWaffle")),
                  tabPanel("Density/Centile Plots", 
                           plotOutput("MorbGraph"),
                           plotOutput("MortGraph")))
      
    )
  )
))
