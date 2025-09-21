📝 Project Description

This project represents a full BI lifecycle combined with AI-powered product discovery. Starting from raw CSV files, we designed and implemented an intelligent data solution covering:

OLTP & OLAP systems

ETL processes

Data Warehousing

Advanced analytics

AI-powered semantic product search & recommendations

The goal was to deliver a smart, efficient, and user-friendly system that improves business insights and enhances customer experience.

🚀 Project Execution Overview
🔹 Database & ETL

Designed ERD & Data Mapping after dataset exploration.

Built an OLTP Database with:

Views for simplified querying.

Stored Procedures to centralize business logic.

Triggers to ensure data integrity on insert/update/delete.

Developed ETL pipelines with SSIS, integrating Reference Data, Master Data, and Transactions.

Designed a Star Schema Data Warehouse (DWH) and migrated OLTP → DWH.

🔹 Analytics & Reporting

Built OLAP Cubes in SSAS.

Created detailed reports with SSRS.

Designed interactive dashboards in Power BI and Tableau, including Pareto Analysis for sales insights.

🔹 AI-Powered Product Discovery

Implemented a semantic search system powered by Sentence-BERT embeddings.

Applied cosine similarity & Euclidean distance to match queries with products.

Integrated Groq Llama-3.3-70B for intelligent recommendations and conversational responses.

Built an interactive Gradio UI for real-time product search and AI-driven suggestions.

Included fallback handling for unavailable products with alternative recommendations.

🛠 Technologies Used

Database & BI: SQL Server (OLTP, SSIS, SSAS, SSRS), Power BI, Tableau

AI & ML: Sentence-BERT, scikit-learn, Groq Llama-3.3-70B

Programming & Tools: Python, Pandas, NumPy, Gradio, Google Colab

👩‍💻 Team Members

Hager Hamed

Youssef Khaled

Sameh A. Yanni

Mohamed Ali

Eslam Abd Elnaby

Under Supervision:
Eng. Mohammed Agoor – Instructor of Data Science & AI, Digital Egypt Pioneers Initiative

🔗 Project Links

GitHub Repository: http://bit.ly/4pCfoTp

Live Demo (Gradio): Coming soon

💡 Conclusion

This project showcases how Business Intelligence and AI can be integrated to provide powerful insights and enhance decision-making. From data pipelines to dashboards and intelligent product discovery, our work highlights the potential of combining traditional BI tools with modern AI systems for smarter retail solutions.
