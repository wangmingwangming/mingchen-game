<!DOCTYPE html>
<html lang="zh">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>星尘收集者 | Stardust Collector</title>
<style>
  @import url('https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700;900&family=Rajdhani:wght@300;400;600&display=swap');

  :root {
    --gold: #ffd700;
    --cyan: #00d4ff;
    --pink: #ff6eb4;
    --dark: #020816;
    --card: rgba(0,20,50,0.7);
  }

  * { margin:0; padding:0; box-sizing:border-box; }

  body {
    background: var(--dark);
    color: white;
    font-family: 'Rajdhani', sans-serif;
    min-height: 100vh;
    overflow-x: hidden;
    cursor: crosshair;
  }

  #stars-bg {
    position: fixed;
    top:0; left:0;
    width:100%; height:100%;
    pointer-events: none;
    z-index: 0;
  }

  .container {
    position: relative;
    z-index: 1;
    max-width: 480px;
    margin: 0 auto;
    padding: 16px;
    min-height: 100vh;
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  /* Header */
  .header {
    text-align: center;
    padding: 12px 0 4px;
  }
  .header h1 {
    font-family: 'Orbitron', monospace;
    font-size: 1.4rem;
    font-weight: 900;
    background: linear-gradient(135deg, var(--cyan), var(--pink));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    letter-spacing: 2px;
  }
  .header p {
    font-size: 0.75rem;
    color: rgba(255,255,255,0.4);
    letter-spacing: 3px;
    margin-top: 2px;
  }

  /* Stats bar */
  .stats {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    gap: 8px;
  }
  .stat-card {
    background: var(--card);
    border: 1px solid rgba(0,212,255,0.15);
    border-radius: 8px;
    padding: 8px;
    text-align: center;
    backdrop-filter: blur(10px);
  }
  .stat-label {
    font-size: 0.6rem;
    color: var(--cyan);
    letter-spacing: 2px;
    text-transform: uppercase;
  }
  .stat-value {
    font-family: 'Orbitron', monospace;
    font-size: 1rem;
    font-weight: 700;
    color: var(--gold);
    margin-top: 2px;
  }

  /* Click zone */
  .click-zone {
    position: relative;
    background: var(--card);
    border: 1px solid rgba(0,212,255,0.2);
    border-radius: 16px;
    height: 240px;
    display: flex;
    align-items: center;
    justify-content: center;
    overflow: hidden;
    backdrop-filter: blur(10px);
    cursor: pointer;
    user-select: none;
    transition: border-color 0.2s;
  }
  .click-zone:hover { border-color: rgba(0,212,255,0.5); }
  .click-zone:active { transform: scale(0.99); }

  .ship-wrap {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 8px;
    pointer-events: none;
  }
  .ship {
    font-size: 4rem;
    filter: drop-shadow(0 0 20px var(--cyan));
    transition: transform 0.1s;
    animation: float 3s ease-in-out infinite;
  }
  .click-zone:active .ship { transform: scale(0.9); }

  @keyframes float {
    0%,100% { transform: translateY(0); }
    50% { transform: translateY(-8px); }
  }

  .click-hint {
    font-size: 0.7rem;
    color: rgba(255,255,255,0.4);
    letter-spacing: 3px;
    text-transform: uppercase;
  }

  .click-zone .glow-ring {
    position: absolute;
    width: 120px; height: 120px;
    border-radius: 50%;
    border: 1px solid rgba(0,212,255,0.2);
    animation: pulse-ring 2s ease-out infinite;
    pointer-events: none;
  }
  .click-zone .glow-ring:nth-child(2) { animation-delay: 0.7s; }
  .click-zone .glow-ring:nth-child(3) { animation-delay: 1.4s; }

  @keyframes pulse-ring {
    0% { transform: scale(0.8); opacity: 0.6; }
    100% { transform: scale(2.5); opacity: 0; }
  }

  /* Floating +1 text */
  .float-text {
    position: fixed;
    font-family: 'Orbitron', monospace;
    font-weight: 700;
    font-size: 1.1rem;
    color: var(--gold);
    pointer-events: none;
    z-index: 999;
    animation: floatUp 0.9s ease-out forwards;
    text-shadow: 0 0 10px var(--gold);
  }
  @keyframes floatUp {
    0% { opacity: 1; transform: translateY(0) scale(1); }
    100% { opacity: 0; transform: translateY(-60px) scale(1.3); }
  }

  /* Upgrades */
  .section-title {
    font-family: 'Orbitron', monospace;
    font-size: 0.65rem;
    color: var(--cyan);
    letter-spacing: 3px;
    text-transform: uppercase;
    padding: 0 4px;
  }

  .upgrades {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .upgrade-btn {
    background: var(--card);
    border: 1px solid rgba(255,255,255,0.1);
    border-radius: 10px;
    padding: 12px 14px;
    display: flex;
    align-items: center;
    gap: 12px;
    cursor: pointer;
    transition: all 0.2s;
    color: white;
    text-align: left;
    width: 100%;
  }
  .upgrade-btn:hover:not(:disabled) {
    border-color: var(--cyan);
    background: rgba(0,212,255,0.08);
    transform: translateX(3px);
  }
  .upgrade-btn:disabled {
    opacity: 0.35;
    cursor: not-allowed;
  }
  .upgrade-btn.maxed {
    border-color: var(--gold);
    opacity: 0.7;
    cursor: not-allowed;
  }

  .upgrad
