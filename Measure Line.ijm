 macro "Measure Line" {
      if (selectionType!=5)
          exit("Straight line selection required");
      getLine(x1, y1, x2, y2, lineWidth);
      getPixelSize(unit, width, height, depth);
      x1*=width; y1*=height; x2*=width; y2*=height; 
      angle = getAngle(x1, y1, x2, y2);
      length = sqrt((x2-x1)*(x2-x1)+(y2-y1)*(y2-y1));
      row = nResults();
      setResult("Angle", row, angle);
      setResult("Length", row, length);
      updateResults();
  }