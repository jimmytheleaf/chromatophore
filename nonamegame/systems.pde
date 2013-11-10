
class TweenSystem extends System {

	HashMap<Tween, TweenVariable> tweens;

	TweenSystem() {
  		super("TweenSystem");
		tweens = new HashMap<Tween, TweenVariable>();

	}

	void addTween(float dur, TweenVariable variable, float target, Easing easing_function) {

		Tween tween = new Tween(variable.initial(), target, dur, easing_function);
		tweens.put(tween, variable);

	}

	void update(float dt) {

  		Tween[] to_remove = new Tween[tweens.size()];
		int index = 0;

		for (Tween tween : tweens.keySet()) {

			TweenVariable variable = tweens.get(tween);

			tween.update(dt);
			variable.setValue(tween.value);

			if (tween.finished()) {
				to_remove[index] = tween;
				index++;
			}

		}

		for (int i = 0; i < index; i++) {
			tweens.remove(to_remove[i]);
		}

	}

}
