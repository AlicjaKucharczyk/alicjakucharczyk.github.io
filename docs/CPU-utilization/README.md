# The Ask

?> <img src="../media/dog.jpeg" width="200"> **Application Owner:** "I just looked into the metrics and see higher CPU usage than normal, along with a high number of succeeded connections. I'm not sure if you can help me with that? These connections come from a new app that is making a lot of short connections. I've checked the CPU utilization, memory utilization, and succeeded connections in the metrics, and this is what I see:"

![Metrics Overview](../media/high-cpu-utilization.png)

# Investigation

To investigate the issues mentioned by the application owner, we'll start by examining the CPU and memory usage, as well as the number of connections. Begin by navigating to the Azure portal. Once there, access the metrics section: 


<img src="../media/metrics.png" width="200">

In the 'Metric' dropdown, search for and select 'CPU percent'. 

<img src="../media/cpu-percent.png">

Next, add another metric: look for 'connections' and choose 'successful connections'. 

<img src="../media/add-metric.png">
<img src="../media/succeeded-connections.png">

Analyze and compare both sets of data to validate the values. You should now see the two metrics plotted one under another in the following way:

![Metrics Overview](../media/high-cpu-utilization.png)


!> It's evident that the CPU utilization increases concurrently with the number of connections. This correlation suggests that multiple short-lived connections can definitely lead to excessively high CPU usage. Understanding this pattern is crucial in identifying the root cause of the performance issue.

Additionally, when you plot the memory utilization, you will notice that the increase in memory usage is barely noticeable. This occurs because the queries run on these connections do not use `work_mem` at all. Each connection, despite being one of thousands, only consumes a small amount of memory. This observation is important as it highlights that a **large number of connections doesn't necessarily translate into significant memory consumption**.


# Solution

After analyzing the CPU and memory utilization alongside the number of connections, it's clear that the high CPU usage correlates with the increased number of connections. This aligns with the common causes of high CPU utilization as outlined in the Azure documentation, particularly in the article ["Troubleshoot high CPU utilization in Azure Database for PostgreSQL - Flexible Server"](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/how-to-high-cpu-utilization?tabs=postgres-13).

## Identifying the Root Cause

In the 'Identify root causes' section of the documentation, two main reasons for high CPU utilization are highlighted:
1. Long-running transactions.
2. Total number of connections and number of connections by state.

Given the Application Owner's observations and the metrics data, it seems likely that the issue is related to the second cause: the total number of connections, especially considering these are numerous short-lived connections.

## Implementing the Solution: PgBouncer

To resolve this issue, the documentation recommends using connection pooling, specifically through PgBouncer. PgBouncer effectively manages connection pooling, reducing the CPU load caused by a high number of connections. Detailed instructions on enabling and configuring PgBouncer for Azure Database for PostgreSQL - Flexible Server can be found here: ["Enabling and configuring PgBouncer"](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-pgbouncer#enabling-and-configuring-pgbouncer).

!> After enabling PgBouncer, no additional settings need to be changed. However, you should inform your Application Owner to switch the application's database connections to use port 6432 instead of the default 5432. This change directs the connections through PgBouncer.


## Monitoring the Changes

Once PgBouncer is enabled and the application is reconfigured to connect through port 6432, allow some time for the changes to reflect in metrics. Then, revisit the Azure metrics. You should observe a notable decrease in CPU utilization and a more manageable number of connections. This exercise demonstrates the effectiveness of PgBouncer in optimizing connection management and reducing CPU strain in Azure Database for PostgreSQL.




?> <img src="../media/dba-dog.png" width="200"> **Application Owner:** "Thank you! After enabling PgBouncer, I see that the CPU utilization went down by around 16 percent!"


![After redirecting connections through PgBouncer](../media/cpuPgBouncer.png)
