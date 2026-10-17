// <alchemy-slider> — the autoplaying carousel on the Galleries tour page.
//
// Attributes:
//   autoplay    present to auto-advance
//   duration    ms each slide is shown (default 4000)
//   transition  ms of the slide animation (default 500)
//   per-slide   slides visible at once (default 1)
//
// As a custom element it needs no Turbo hooks: connectedCallback runs when the
// page is shown, disconnectedCallback tears the timer down on navigation.
class AlchemySlider extends HTMLElement {
  connectedCallback() {
    this.track = this.querySelector("[data-slider-track]")
    if (!this.track) return
    this.viewport = this.querySelector("[data-slider-viewport]")
    this.slides = Array.from(this.track.children)
    this.index = 0

    // JS is present: swap the no-JS scroll fallback for a transform carousel.
    if (this.viewport) this.viewport.style.overflow = "hidden"
    this.track.style.transitionProperty = "transform"
    this.track.style.transitionDuration = `${this.transition}ms`

    this._prev = () => { this.stop(); this.move(-1) }
    this._next = () => { this.stop(); this.move(1) }
    this._stop = this.stop.bind(this)
    this._start = this.start.bind(this)
    this.querySelector("[data-slider-prev]")?.addEventListener("click", this._prev)
    this.querySelector("[data-slider-next]")?.addEventListener("click", this._next)
    this.addEventListener("mouseenter", this._stop)
    this.addEventListener("mouseleave", this._start)

    this.update()
    this.start()
  }

  disconnectedCallback() {
    this.stop()
  }

  get perSlide() { return Math.max(1, parseInt(this.getAttribute("per-slide"), 10) || 1) }
  get duration() { return parseInt(this.getAttribute("duration"), 10) || 4000 }
  get transition() {
    const t = parseInt(this.getAttribute("transition"), 10)
    return Number.isFinite(t) ? t : 500
  }
  get autoplay() { return this.hasAttribute("autoplay") }
  get maxIndex() { return Math.max(0, this.slides.length - this.perSlide) }

  update() {
    this.track.style.transform = `translateX(-${this.index * (100 / this.perSlide)}%)`
  }

  move(step) {
    this.index += step
    if (this.index > this.maxIndex) this.index = 0
    if (this.index < 0) this.index = this.maxIndex
    this.update()
  }

  start() {
    if (!this.autoplay || this.slides.length <= this.perSlide) return
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return
    this.stop()
    this.timer = window.setInterval(() => this.move(1), this.duration)
  }

  stop() {
    if (this.timer) {
      window.clearInterval(this.timer)
      this.timer = null
    }
  }
}

if (!customElements.get("alchemy-slider")) {
  customElements.define("alchemy-slider", AlchemySlider)
}
