import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['campaignSelect', 'adsetSelect', 'loader', 'reload'];

  connect() {
    console.log("Campaigns controller connected!");

    if (this.hasGeneratingPrompts()) {
      this.showLoader();
      this.reloadPageAfterDelay();
    } else {
      this.hideLoader();
    }

    if (this.hasGeneratingImages()) {
      this.reloadPageAfterDelay();
    }

    const campaignSelect = this.campaignSelectTarget;

    campaignSelect.addEventListener("change", (event) => {
      const campaignId = event.target.value;

      fetch(`/tiktok/adsets?campaign_id=${encodeURIComponent(campaignId)}`, {
        method: "GET"
      })
      .then(response => response.json())
      .then(data => {
        console.log(data);
        this.updateAdsetOptions(data);
      })
      .catch(error => {
        console.error("Error:", error);
      });
    });
  }

  updateAdsetOptions(adsets) {
    const adsetSelect = this.adsetSelectTarget;
    adsetSelect.innerHTML = ""; // Clear existing options

    // Add a default "Select an adset" option
    const defaultOption = document.createElement("option");
    defaultOption.value = "";
    defaultOption.textContent = "Select an adset";
    adsetSelect.appendChild(defaultOption);

    // Populate with new options
    adsets.forEach(adset => {
      const option = document.createElement("option");
      option.value = adset[1]; // adgroup_id
      option.textContent = adset[0]; // adgroup_name
      adsetSelect.appendChild(option);
    });
  }

  hasGeneratingPrompts() {
    // Check if the `campaign.generating_prompts` is true from the server-side rendered HTML.
    // You can also modify this logic based on the campaign status.
    return document.querySelector('.wait') !== null;
  }

  hasGeneratingImages() {
    // Check if the `campaign.generating_prompts` is true from the server-side rendered HTML.
    // You can also modify this logic based on the campaign status.
    return document.querySelector('.image-loader') !== null;
  }

  showLoader() {
    this.loaderTarget.style.display = "block";  // Show loader
  }

  hideLoader() {
    this.loaderTarget.style.display = "none";  // Hide loader
  }

  reloadPageAfterDelay() {
    const reload = this.reloadTarget;
    // Reload the page after 10 seconds if waiting
    setTimeout(() => {
      reload.click();
    }, 10000);
  }
}
