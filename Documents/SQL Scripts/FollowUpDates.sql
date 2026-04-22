USE [JobTracking]
GO

/****** Object:  StoredProcedure [dbo].[FollowUpDates]    Script Date: 4/22/2026 4:59:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[FollowUpDates]
AS
BEGIN
    SET NOCOUNT ON;
/*
    Company AS EndClient,
    NULL AS PrimeVendor,
    NULL AS SourcingAgency,
*/
SELECT
    A.ApplicationID,
    A.EndClient,
    A.PrimeVendor,
    A.[SourcingAgency],
    --A.Company,
    A.Position,
    A.DateApplied,
    F.FollowUpDate,
    
    CASE
        -- If "Not Hired" appears, no next follow-up
        WHEN A.Notes LIKE '%Not Hired%' THEN NULL

        -- If a follow-up exists, use its stored NextFollowUpDate
        WHEN F.NextFollowUpDate IS NOT NULL THEN F.NextFollowUpDate

        -- Otherwise calculate next follow-up from DateApplied
        ELSE
            DATEADD(day, 14, A.DateApplied)
    END AS NextFollowUpDate,

    A.Notes AS [Application Notes],
    F.Notes AS [Follow Up Notes]

FROM
    Applications AS A

    -- Get the latest follow-up per application
    LEFT JOIN (
        SELECT F1.*
        FROM FollowUps AS F1
        INNER JOIN (
            SELECT ApplicationID, MAX(FollowUpDate) AS LatestFollowUp
            FROM FollowUps
            GROUP BY ApplicationID
        ) AS X
            ON F1.ApplicationID = X.ApplicationID
            AND F1.FollowUpDate = X.LatestFollowUp
    ) AS F
        ON A.ApplicationID = F.ApplicationID

ORDER BY
    A.DateApplied DESC;
END;

GO


