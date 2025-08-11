using eBarbershop.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace eBarbershop.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [Authorize(Roles = "Admin")]
    public class WaitingListAnalyticsController : ControllerBase
    {
        private readonly IWaitingListAnalyticsService _analyticsService;

        public WaitingListAnalyticsController(IWaitingListAnalyticsService analyticsService)
        {
            _analyticsService = analyticsService;
        }

        [HttpGet("overview")]
        public async Task<ActionResult<WaitingListAnalytics>> GetAnalytics(
            [FromQuery] int? frizerId = null,
            [FromQuery] DateTime? fromDate = null,
            [FromQuery] DateTime? toDate = null)
        {
            var result = await _analyticsService.GetAnalytics(frizerId, fromDate, toDate);
            return Ok(result);
        }

        [HttpGet("peak-times")]
        public async Task<ActionResult<List<PeakTimeAnalysis>>> GetPeakTimesAnalysis([FromQuery] int? frizerId = null)
        {
            var result = await _analyticsService.GetPeakTimesAnalysis(frizerId);
            return Ok(result);
        }

        [HttpGet("customer-behavior/{klijentId}")]
        public async Task<ActionResult<CustomerBehaviorAnalysis>> GetCustomerBehaviorAnalysis(int klijentId)
        {
            var result = await _analyticsService.GetCustomerBehaviorAnalysis(klijentId);
            return Ok(result);
        }

        [HttpGet("ml-effectiveness")]
        public async Task<ActionResult<List<RecommendationEffectiveness>>> GetRecommendationEffectiveness()
        {
            var result = await _analyticsService.GetRecommendationEffectiveness();
            return Ok(result);
        }
    }
}